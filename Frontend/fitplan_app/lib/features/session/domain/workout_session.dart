import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

/// The full session (GET /api/sessions/active, /api/sessions/{id}).
@freezed
abstract class WorkoutSession with _$WorkoutSession {
  const WorkoutSession._();

  const factory WorkoutSession({
    required String id,
    required String name,
    String? workoutPlanId,
    required DateTime startedAt,
    DateTime? completedAt,
    String? notes,
    @Default([]) List<SessionExercise> exercises,
    @Default([]) List<CardioEntry> cardio,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);

  int get setCount => exercises.fold(0, (sum, e) => sum + e.sets.length);

  /// The API refuses to finish a session with nothing logged.
  bool get hasAnythingLogged => setCount > 0 || cardio.isNotEmpty;
}

@freezed
abstract class SessionExercise with _$SessionExercise {
  const SessionExercise._();

  const factory SessionExercise({
    required String id,
    required String exerciseId,
    required String name,
    required String gifUrl,
    required String bodyPart,
    required int order,
    int? targetSets,
    int? targetReps,
    @Default([]) List<SessionSet> sets,
    LastPerformance? lastPerformance,
  }) = _SessionExercise;

  factory SessionExercise.fromJson(Map<String, dynamic> json) => _$SessionExerciseFromJson(json);

  /// Done when every target set is logged (or at least one set without a target).
  bool get isDone => sets.isNotEmpty && sets.length >= (targetSets ?? 1);
}

@freezed
abstract class SessionSet with _$SessionSet {
  const factory SessionSet({
    required String id,
    required int setNumber,
    required int reps,
    double? weightKg,
  }) = _SessionSet;

  factory SessionSet.fromJson(Map<String, dynamic> json) => _$SessionSetFromJson(json);
}

/// What the user did the last time with this exercise.
@freezed
abstract class LastPerformance with _$LastPerformance {
  const factory LastPerformance({
    required DateTime performedAt,
    @Default([]) List<SessionSet> sets,
  }) = _LastPerformance;

  factory LastPerformance.fromJson(Map<String, dynamic> json) => _$LastPerformanceFromJson(json);
}

enum CardioMachine {
  @JsonValue('Treadmill')
  treadmill('Treadmill', supportsIncline: true),
  @JsonValue('StationaryBike')
  stationaryBike('Bike'),
  @JsonValue('Elliptical')
  elliptical('Elliptical'),
  @JsonValue('StairClimber')
  stairClimber('Stairs'),
  @JsonValue('Rower')
  rower('Rower'),
  @JsonValue('Other')
  other('Other');

  const CardioMachine(this.label, {this.supportsIncline = false});

  final String label;
  final bool supportsIncline;

  /// The value the API expects (JsonStringEnumConverter).
  String get apiValue => switch (this) {
        treadmill => 'Treadmill',
        stationaryBike => 'StationaryBike',
        elliptical => 'Elliptical',
        stairClimber => 'StairClimber',
        rower => 'Rower',
        other => 'Other',
      };
}

@freezed
abstract class CardioEntry with _$CardioEntry {
  const factory CardioEntry({
    required String id,
    required CardioMachine machine,
    required int durationSeconds,
    double? speedKmh,
    double? inclinePercent,
    double? distanceKm,
    int? estimatedCalories,
  }) = _CardioEntry;

  factory CardioEntry.fromJson(Map<String, dynamic> json) => _$CardioEntryFromJson(json);
}

/// A completed session in short (POST .../complete and the history list).
@freezed
abstract class SessionSummary with _$SessionSummary {
  const factory SessionSummary({
    required String id,
    required String name,
    required DateTime startedAt,
    required DateTime completedAt,
    required int durationSeconds,
    required int exerciseCount,
    required int setCount,
    required double totalVolumeKg,
    required int cardioDurationSeconds,
    required int estimatedCalories,
  }) = _SessionSummary;

  factory SessionSummary.fromJson(Map<String, dynamic> json) => _$SessionSummaryFromJson(json);
}

/// Limits from the API.
abstract final class SessionLimits {
  static const maxSetsPerExercise = 10;
  static const maxReps = 100;
  static const maxWeightKg = 500.0;
}
