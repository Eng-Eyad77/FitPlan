import 'package:fitplan_app/features/history/application/history_controller.dart';
import 'package:fitplan_app/features/session/domain/workout_session.dart';
import 'package:flutter_test/flutter_test.dart';

SessionSummary _doneAt(DateTime completedAt) => SessionSummary(
      id: completedAt.toIso8601String(),
      name: 'Push day',
      startedAt: completedAt.subtract(const Duration(hours: 1)),
      completedAt: completedAt,
      durationSeconds: 3600,
      exerciseCount: 1,
      setCount: 3,
      totalVolumeKg: 1000,
      cardioDurationSeconds: 0,
      estimatedCalories: 0,
    );

void main() {
  // Tuesday 3 November 2026
  final now = DateTime(2026, 11, 3, 18);

  test('week starting Sunday puts each workout on its day', () {
    final counts = sessionsPerDay([
      _doneAt(DateTime(2026, 11, 1, 9)), // Sunday
      _doneAt(DateTime(2026, 11, 3, 7)), // Tuesday
      _doneAt(DateTime(2026, 11, 3, 17)), // Tuesday again
    ], now);

    expect(counts, [1, 0, 2, 0, 0, 0, 0]);
  });

  test('workouts from last week are ignored', () {
    final counts = sessionsPerDay([_doneAt(DateTime(2026, 10, 31, 20))], now); // Saturday before
    expect(counts.every((c) => c == 0), isTrue);
  });

  test('week starting Saturday includes that Saturday', () {
    final counts = sessionsPerDay(
      [_doneAt(DateTime(2026, 10, 31, 20))],
      now,
      firstDayOfWeek: DateTime.saturday,
    );
    expect(counts, [1, 0, 0, 0, 0, 0, 0]);
  });
}
