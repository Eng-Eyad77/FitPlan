import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fitplan_app/core/storage/session_storage.dart';
import 'package:fitplan_app/features/auth/domain/auth_session.dart';
import 'package:fitplan_app/features/profile/application/profile_controller.dart';
import 'package:fitplan_app/features/profile/domain/profile.dart';
import 'package:fitplan_app/features/session/application/active_session_controller.dart';
import 'package:fitplan_app/features/session/data/sessions_repository.dart';
import 'package:fitplan_app/features/session/domain/workout_session.dart';
import 'package:fitplan_app/features/session/presentation/cardio_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

// Phase 8 (4.3, 4.4): each machine asks only for what its display shows; Other is gone, Swimming is new.

class _FakeSessions extends SessionsRepository {
  _FakeSessions() : super(Dio());

  final sent = <Map<String, dynamic>>[];

  @override
  Future<WorkoutSession?> getActive() async => WorkoutSession(id: 's1', name: 'Quick Workout', startedAt: DateTime.now());

  @override
  Future<CardioEntry> addCardio(String sessionId, CardioInput input) async {
    sent.add(input.toJson());
    return CardioEntry(id: 'c${sent.length}', machine: input.machine, durationSeconds: input.durationSeconds);
  }
}

class _NoAuth extends SessionStorage {
  _NoAuth() : super(const FlutterSecureStorage());

  @override
  Future<AuthSession?> read() async => null;
}

class _NoProfile extends ProfileController {
  @override
  Future<Profile> build() => Completer<Profile>().future; // never loads: no weight known
}

Future<_FakeSessions> _openSheet(WidgetTester tester) async {
  final sessions = _FakeSessions();
  await tester.binding.setSurfaceSize(const Size(420, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sessionsRepositoryProvider.overrideWithValue(sessions),
      sessionStorageProvider.overrideWithValue(_NoAuth()),
      profileControllerProvider.overrideWith(_NoProfile.new),
    ],
    child: MaterialApp(
      home: Consumer(builder: (context, ref, _) {
        ref.watch(activeSessionControllerProvider);
        return TextButton(onPressed: () => showCardioSheet(context), child: const Text('open'));
      }),
    ),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return sessions;
}

Future<void> _pick(WidgetTester tester, String machine) async {
  await tester.tap(find.text(machine));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String label, String value) async {
  await tester.enterText(find.widgetWithText(TextField, label), value);
}

void main() {
  testWidgets('the picker has Swimming and no Other', (tester) async {
    await _openSheet(tester);

    for (final label in ['Treadmill', 'Stairs', 'Bike', 'Elliptical', 'Rower', 'Swimming']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Other'), findsNothing);
  });

  testWidgets('stairs ask for level and floors, never speed, and send only those', (tester) async {
    final sessions = await _openSheet(tester);

    // speed typed on the treadmill first, then the machine changed
    await tester.tap(find.text('More details (optional)'));
    await tester.pumpAndSettle();
    await _type(tester, 'Speed', '9');
    await _pick(tester, 'Stairs');

    expect(find.widgetWithText(TextField, 'Speed'), findsNothing);
    expect(find.widgetWithText(TextField, 'Level'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Floors'), findsOneWidget);
    await _type(tester, 'Level', '8');
    await _type(tester, 'Floors', '45');
    await tester.tap(find.widgetWithText(FilledButton, 'Add cardio'));
    await tester.pumpAndSettle();

    expect(sessions.sent.single, {'machine': 'StairClimber', 'durationSeconds': 900, 'level': 8, 'floors': 45});
  });

  testWidgets('a value outside the machine limits is caught before sending', (tester) async {
    final sessions = await _openSheet(tester);

    await _pick(tester, 'Rower');
    await tester.tap(find.text('More details (optional)'));
    await tester.pumpAndSettle();
    await _type(tester, 'Damper', '11');
    await tester.tap(find.widgetWithText(FilledButton, 'Add cardio'));
    await tester.pumpAndSettle();

    expect(find.text('Damper: 1 to 10'), findsOneWidget);
    expect(sessions.sent, isEmpty);
  });

  testWidgets('swimming asks for metres, pool length and laps', (tester) async {
    final sessions = await _openSheet(tester);

    await _pick(tester, 'Swimming');
    await tester.tap(find.text('More details (optional)'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Distance'), findsOneWidget);
    expect(find.textContaining('the distance is worked out for you'), findsOneWidget);
    await _type(tester, 'Pool length', '25');
    await _type(tester, 'Laps', '40');
    await tester.tap(find.widgetWithText(FilledButton, 'Add cardio'));
    await tester.pumpAndSettle();

    expect(sessions.sent.single, {'machine': 'Swimming', 'durationSeconds': 900, 'poolLengthMeters': 25, 'laps': 40});
  });

  test('each machine has its own fields', () {
    expect(CardioMachine.stairClimber.fields, [CardioField.level, CardioField.floors]);
    expect(CardioMachine.treadmill.fields, [CardioField.speed, CardioField.incline, CardioField.distanceKm]);
    expect(CardioMachine.rower.fields.map((f) => f.jsonKey), ['distanceMeters', 'level', 'strokeRate']);
    expect(CardioMachine.choices, isNot(contains(CardioMachine.other)));
    expect(CardioMachine.choices, isNot(contains(CardioMachine.unknown)));
  });

  test('a machine this version does not know still loads the workout', () {
    final session = WorkoutSession.fromJson({
      'id': 's1',
      'name': 'Quick Workout',
      'startedAt': '2026-11-19T10:00:00Z',
      'cardio': [
        {'id': 'c1', 'machine': 'Kayak', 'durationSeconds': 600},
        {'id': 'c2', 'machine': 'Swimming', 'durationSeconds': 1800, 'distanceMeters': 1500},
        {'id': 'c3', 'machine': 'Other', 'durationSeconds': 600, 'distanceKm': 2},
      ],
    });

    expect(session.cardio.map((c) => c.machine), [CardioMachine.unknown, CardioMachine.swimming, CardioMachine.other]);
    expect(session.cardio.first.machine.label, 'Cardio');
    expect(session.cardio[2].details, ['2 km']); // old Other entries still show
  });

  test('the details read like the machine display', () {
    CardioEntry e(CardioMachine m, Map<String, Object> json) =>
        CardioEntry.fromJson({'id': 'c', 'machine': m.apiValue, 'durationSeconds': 60, ...json});

    expect(e(CardioMachine.treadmill, {'speedKmh': 8.5, 'inclinePercent': 2.0, 'distanceKm': 3.0}).details,
        ['8.5 km/h', '2% incline', '3 km']);
    expect(e(CardioMachine.stairClimber, {'level': 8, 'floors': 45}).details, ['Level 8', '45 floors']);
    expect(e(CardioMachine.rower, {'distanceMeters': 2000, 'level': 5, 'strokeRate': 24}).details,
        ['2000 m', 'Damper 5', '24 spm']);
    expect(e(CardioMachine.swimming, {'distanceMeters': 1500, 'poolLengthMeters': 25, 'laps': 60}).details,
        ['1500 m', '60 laps of 25 m']);
    expect(e(CardioMachine.stationaryBike, {'level': 12, 'cadenceRpm': 85}).details, ['Level 12', '85 rpm']);
  });
}
