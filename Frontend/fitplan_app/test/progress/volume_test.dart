import 'dart:async';

import 'package:fitplan_app/features/progress/application/progress_providers.dart';
import 'package:fitplan_app/features/progress/domain/stats.dart';
import 'package:fitplan_app/features/progress/domain/volume.dart';
import 'package:fitplan_app/features/progress/presentation/volume_card.dart';
import 'package:fitplan_app/features/session/domain/workout_session.dart';
import 'package:fitplan_app/features/session/presentation/summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _volumeJson(double total, Map<String, String> reached) => {
      'totalVolumeKg': total,
      'milestones': [
        for (final m in Milestone.all)
          {'key': m.key, 'thresholdKg': m.weightKg, 'reachedAt': reached[m.key]},
      ],
    };

SessionSummary _summary({double volume = 6240, List<String> newMilestones = const []}) => SessionSummary(
      id: 's1',
      name: 'Push day',
      startedAt: DateTime(2026, 11, 22, 17),
      completedAt: DateTime(2026, 11, 22, 18),
      durationSeconds: 3480,
      exerciseCount: 4,
      setCount: 18,
      totalVolumeKg: volume,
      cardioDurationSeconds: 0,
      estimatedCalories: 0,
      newMilestones: newMilestones,
    );

void main() {
  group('the comparison line', () {
    test('uses the biggest object passed, one decimal under 10', () {
      expect(Milestone.compare(8420), 'About 1.4 elephants');
      expect(Milestone.compare(6240), 'About an elephant');
      expect(Milestone.compare(5999), 'About 6 small cars');
      expect(Milestone.compare(1500), 'About 1.5 small cars');
    });

    test('says "a" for about one, and whole numbers from 10', () {
      expect(Milestone.compare(1020), 'About a small car');
      expect(Milestone.compare(500), 'About a grand piano');
      expect(Milestone.compare(130000), 'About 3.3 loaded trucks');
      expect(Milestone.compare(25 * 450000), 'About 25 jumbo jets');
    });

    test('is empty under the smallest object', () {
      expect(Milestone.compare(0), isNull);
      expect(Milestone.compare(499), isNull);
    });
  });

  test('kg under 1,000, tonnes above', () {
    expect(formatVolumeAmount(840), '840 kg');
    expect(formatVolumeAmount(8420), '8.4 t');
    expect(formatVolumeAmount(12400), '12.4 t');
    expect(formatVolumeAmount(2100000), '2,100 t');
  });

  test('reads the milestones and skips keys this app does not know', () {
    final json = _volumeJson(8420, {
      'grand-piano': '2026-11-03T18:00:00Z',
      'small-car': '2026-11-03T18:00:00Z',
      'elephant': '2026-11-12T18:00:00Z',
    });
    (json['milestones'] as List).add({'key': 'moon', 'thresholdKg': 1e20, 'reachedAt': null});

    final volume = VolumeStats.fromJson(json);

    expect(volume.milestones, hasLength(7));
    expect(volume.next!.milestone.key, 'city-bus');
    expect(volume.progressToNext, closeTo(8420 / 12000, 0.001));
    expect(volume.milestones[2].reachedAt, DateTime.utc(2026, 11, 12, 18));
  });

  test('a badge kept after a delete: the next one is the first not reached', () {
    // reached the car, then a workout was deleted and the total went under it
    final volume = VolumeStats.fromJson(
      _volumeJson(700, {'grand-piano': '2026-11-03T18:00:00Z', 'small-car': '2026-11-04T18:00:00Z'}),
    );

    expect(volume.next!.milestone.key, 'elephant');
    expect(volume.progressToNext, closeTo(700 / 6000, 0.001));
  });

  group('screens', () {
    Future<void> pumpCard(WidgetTester tester, VolumeStats volume) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [volumeProvider.overrideWith((ref) async => volume)],
        child: const MaterialApp(home: Scaffold(body: VolumeCard())),
      ));
      await tester.pump();
    }

    testWidgets('Progress shows the total, the comparison and the way to the next', (tester) async {
      await pumpCard(
        tester,
        VolumeStats.fromJson(_volumeJson(8420, {
          'grand-piano': '2026-11-03T18:00:00Z',
          'small-car': '2026-11-03T18:00:00Z',
          'elephant': '2026-11-12T18:00:00Z',
        })),
      );

      expect(find.textContaining('8.4'), findsOneWidget);
      expect(find.text('About 1.4 elephants'), findsOneWidget);
      expect(find.text('Next: a city bus'), findsOneWidget);
      expect(find.text('3.6 t to go'), findsOneWidget);
    });

    testWidgets('tapping the card lists every milestone', (tester) async {
      await pumpCard(
        tester,
        VolumeStats.fromJson(_volumeJson(1200, {
          'grand-piano': '2026-11-03T18:00:00Z',
          'small-car': '2026-11-05T18:00:00Z',
        })),
      );

      await tester.tap(find.byType(VolumeCard));
      await tester.pumpAndSettle();

      expect(find.text('Milestones'), findsOneWidget);
      expect(find.text('A grand piano'), findsOneWidget);
      expect(find.textContaining('Reached'), findsNWidgets(2));
      await tester.scrollUntilVisible(find.text('A jumbo jet at takeoff'), 200, scrollable: find.byType(Scrollable).last);
      expect(find.text('A jumbo jet at takeoff'), findsOneWidget);
    });

    testWidgets('a new user is told how to start', (tester) async {
      await pumpCard(tester, VolumeStats.fromJson(_volumeJson(0, {})));

      expect(find.text('Finish a workout with weights to start'), findsOneWidget);
      expect(find.text('Next: a grand piano'), findsOneWidget);
    });

    Future<void> pumpSummary(WidgetTester tester, SessionSummary summary) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          // the comparison with the previous workout never arrives here
          sessionComparisonProvider.overrideWith((ref, id) => Completer<SessionComparison>().future),
        ],
        child: MaterialApp(home: SummaryScreen(summary: summary)),
      ));
      await tester.pump(const Duration(seconds: 2));
    }

    testWidgets('the summary celebrates the milestones this workout crossed', (tester) async {
      await pumpSummary(tester, _summary(newMilestones: ['grand-piano', 'small-car', 'elephant']));

      expect(find.text('NEW MILESTONE'), findsOneWidget);
      expect(find.text("You've lifted an elephant"), findsOneWidget);
      expect(find.text('And passed a small car and a grand piano on the way'), findsOneWidget);
    });

    testWidgets('a usual summary has only the comparison line', (tester) async {
      await pumpSummary(tester, _summary());

      expect(find.text('NEW MILESTONE'), findsNothing);
      await tester.scrollUntilVisible(find.text('This workout: about an elephant'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('This workout: about an elephant'), findsOneWidget);
    });
  });
}
