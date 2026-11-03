import 'package:fitplan_app/features/session/application/rest_timer.dart';
import 'package:fitplan_app/features/session/domain/workout_session.dart';
import 'package:fitplan_app/features/session/presentation/widgets/set_rows.dart';
import 'package:fitplan_app/shared/format.dart';
import 'package:flutter_test/flutter_test.dart';

SessionExercise _exercise({int? targetSets, int logged = 0}) => SessionExercise(
      id: 'e1',
      exerciseId: 'x',
      name: 'bench press',
      gifUrl: '',
      bodyPart: 'chest',
      order: 1,
      targetSets: targetSets,
      targetReps: targetSets == null ? null : 10,
      sets: [
        for (var i = 1; i <= logged; i++) SessionSet(id: 's$i', setNumber: i, reps: 10, weightKg: 60),
      ],
    );

void main() {
  group('format', () {
    test('formatKg drops .0 only', () {
      expect(formatKg(60), '60');
      expect(formatKg(62.5), '62.5');
    });

    test('formatClock', () {
      expect(formatClock(75), '1:15');
      expect(formatClock(3725), '1:02:05');
    });

    test('formatDuration', () {
      expect(formatDuration(2700), '45 min');
      expect(formatDuration(4500), '1 h 15 min');
      expect(formatDuration(3600), '1 h');
    });

    test('formatDaysAgo uses calendar days', () {
      final now = DateTime(2026, 11, 3, 9);
      expect(formatDaysAgo(DateTime(2026, 11, 3, 1), now), 'today');
      expect(formatDaysAgo(DateTime(2026, 11, 2, 23), now), 'yesterday');
      expect(formatDaysAgo(DateTime(2026, 10, 30, 12), now), '4 days ago');
    });
  });

  group('SessionExercise.isDone', () {
    test('needs every target set', () {
      expect(_exercise(targetSets: 3, logged: 2).isDone, isFalse);
      expect(_exercise(targetSets: 3, logged: 3).isDone, isTrue);
    });

    test('without a target, one set is enough', () {
      expect(_exercise(logged: 0).isDone, isFalse);
      expect(_exercise(logged: 1).isDone, isTrue);
    });
  });

  group('RestTimer', () {
    final start = DateTime(2026, 1, 1, 10);
    final timer = RestTimer(endsAt: start.add(const Duration(seconds: 90)), total: const Duration(seconds: 90));

    test('counts down and never goes below zero', () {
      expect(timer.secondsLeft(start), 90);
      expect(timer.secondsLeft(start.add(const Duration(milliseconds: 89500))), 1);
      expect(timer.secondsLeft(start.add(const Duration(seconds: 120))), 0);
    });

    test('progress goes from 1 to 0', () {
      expect(timer.progress(start), 1);
      expect(timer.progress(start.add(const Duration(seconds: 45))), closeTo(0.5, 0.001));
      expect(timer.progress(start.add(const Duration(seconds: 200))), 0);
    });
  });

  group('validateSet', () {
    test('accepts bodyweight (empty kg)', () {
      expect(validateSet(reps: 10, kgText: '', kg: null), isNull);
    });

    test('rejects out of range values', () {
      expect(validateSet(reps: 0, kgText: '', kg: null), isNotNull);
      expect(validateSet(reps: 101, kgText: '', kg: null), isNotNull);
      expect(validateSet(reps: 10, kgText: '501', kg: 501), isNotNull);
      expect(validateSet(reps: 10, kgText: '1.2.3', kg: null), isNotNull);
    });
  });

  test('CardioMachine reads the API values', () {
    final entry = CardioEntry.fromJson({
      'id': 'c1',
      'machine': 'StairClimber',
      'durationSeconds': 600,
      'estimatedCalories': null,
    });
    expect(entry.machine, CardioMachine.stairClimber);
    expect(entry.machine.apiValue, 'StairClimber');
  });
}
