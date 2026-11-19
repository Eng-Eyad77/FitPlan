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

    /// Rest after each set, in seconds. Null = the default (90 s).
    int? restSeconds,
    @Default([]) List<SessionSet> sets,
    LastPerformance? lastPerformance,
    Suggestion? suggestion,
  }) = _SessionExercise;

  factory SessionExercise.fromJson(Map<String, dynamic> json) => _$SessionExerciseFromJson(json);

  /// Done when every target set is logged (or at least one set without a target).
  bool get isDone => sets.isNotEmpty && sets.length >= (targetSets ?? 1);

  /// The rest to count down after a set.
  int get restOrDefault => restSeconds ?? RestLimits.defaultSeconds;
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

enum SuggestionReason {
  @JsonValue('IncreaseWeight')
  increaseWeight,
  @JsonValue('RepeatWeight')
  repeatWeight,
  @JsonValue('Deload')
  deload,
  @JsonValue('MoreReps')
  moreReps,
}

/// What to try today, worked out by the API from the last two times.
@freezed
abstract class Suggestion with _$Suggestion {
  const Suggestion._();

  const factory Suggestion({
    double? weightKg,
    required int reps,
    required SuggestionReason reason,
  }) = _Suggestion;

  factory Suggestion.fromJson(Map<String, dynamic> json) => _$SuggestionFromJson(json);

  /// Why, in a few words.
  String get why => switch (reason) {
        SuggestionReason.increaseWeight => 'you hit every rep last time',
        SuggestionReason.repeatWeight => 'same weight, beat the reps',
        SuggestionReason.deload => 'lighter to recover after two tough workouts',
        SuggestionReason.moreReps => 'one more rep than your best',
      };
}

/// A detail a cardio machine can show. Same names and limits as the API (CardioFields, CardioEntryRequestDto).
enum CardioField {
  speed('speedKmh', 'Speed', 'km/h', min: 0.1, max: 30, decimal: true),
  incline('inclinePercent', 'Incline', '%', min: 0, max: 40, decimal: true),
  distanceKm('distanceKm', 'Distance', 'km', min: 0.01, max: 100, decimal: true),
  distanceMeters('distanceMeters', 'Distance', 'm', min: 1, max: 50000),
  level('level', 'Level', '', min: 1, max: 30),
  damper('level', 'Damper', '', min: 1, max: 10), // the rower's "level"
  floors('floors', 'Floors', '', min: 1, max: 1000),
  cadence('cadenceRpm', 'Cadence', 'rpm', min: 20, max: 200),
  strokeRate('strokeRate', 'Stroke rate', 'spm', min: 10, max: 60),
  poolLength('poolLengthMeters', 'Pool length', 'm', min: 10, max: 100),
  laps('laps', 'Laps', '', min: 1, max: 2000);

  const CardioField(this.jsonKey, this.label, this.unit, {required this.min, required this.max, this.decimal = false});

  final String jsonKey;
  final String label;
  final String unit;
  final num min;
  final num max;
  final bool decimal;

  /// "Speed: 0.1 to 30 km/h"
  String get rangeText => '$label: ${_n(min)} to ${_n(max)}${unit.isEmpty ? '' : ' $unit'}';

  static String _n(num v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';
}

enum CardioMachine {
  @JsonValue('Treadmill')
  treadmill('Treadmill', [CardioField.speed, CardioField.incline, CardioField.distanceKm]),
  @JsonValue('StairClimber')
  stairClimber('Stairs', [CardioField.level, CardioField.floors]),
  @JsonValue('StationaryBike')
  stationaryBike('Bike', [CardioField.level, CardioField.distanceKm, CardioField.cadence]),
  @JsonValue('Elliptical')
  elliptical('Elliptical', [CardioField.level, CardioField.distanceKm, CardioField.incline]),
  @JsonValue('Rower')
  rower('Rower', [CardioField.distanceMeters, CardioField.damper, CardioField.strokeRate]),
  @JsonValue('Swimming')
  swimming('Swimming', [CardioField.distanceMeters, CardioField.poolLength, CardioField.laps]),

  /// Kept for entries saved before it was retired; it can't be picked.
  @JsonValue('Other')
  other('Other', [CardioField.speed, CardioField.incline, CardioField.distanceKm], selectable: false),

  /// A machine this version doesn't know yet (added by a newer server). Shown as plain cardio.
  unknown('Cardio', [], selectable: false);

  const CardioMachine(this.label, this.fields, {this.selectable = true});

  final String label;

  /// What this machine shows on its display, in the order the sheet asks for them.
  final List<CardioField> fields;
  final bool selectable;

  static List<CardioMachine> get choices => [for (final m in values) if (m.selectable) m];

  /// The value the API expects (JsonStringEnumConverter).
  String get apiValue => switch (this) {
        treadmill => 'Treadmill',
        stationaryBike => 'StationaryBike',
        elliptical => 'Elliptical',
        stairClimber => 'StairClimber',
        rower => 'Rower',
        swimming => 'Swimming',
        other => 'Other',
        unknown => throw StateError('An unknown machine is never sent'),
      };
}

@freezed
abstract class CardioEntry with _$CardioEntry {
  const CardioEntry._();

  const factory CardioEntry({
    required String id,
    // a machine from a newer server must not break the whole workout
    @JsonKey(unknownEnumValue: CardioMachine.unknown) required CardioMachine machine,
    required int durationSeconds,
    double? speedKmh,
    double? inclinePercent,
    double? distanceKm,
    int? level,
    int? floors,
    int? cadenceRpm,
    int? strokeRate,
    int? distanceMeters,
    int? poolLengthMeters,
    int? laps,
    int? estimatedCalories,
  }) = _CardioEntry;

  factory CardioEntry.fromJson(Map<String, dynamic> json) => _$CardioEntryFromJson(json);

  /// "1500 m · 60 laps of 25 m", without the duration.
  List<String> get details {
    String n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';
    return [
      if (speedKmh != null) '${n(speedKmh!)} km/h',
      if (inclinePercent != null) '${n(inclinePercent!)}% incline',
      if (distanceKm != null) '${n(distanceKm!)} km',
      if (distanceMeters != null) '$distanceMeters m',
      if (level != null) machine == CardioMachine.rower ? 'Damper $level' : 'Level $level',
      if (floors != null) '$floors ${floors == 1 ? 'floor' : 'floors'}',
      if (cadenceRpm != null) '$cadenceRpm rpm',
      if (strokeRate != null) '$strokeRate spm',
      if (laps != null && poolLengthMeters != null)
        '$laps ${laps == 1 ? 'lap' : 'laps'} of $poolLengthMeters m'
      else if (laps != null)
        '$laps ${laps == 1 ? 'lap' : 'laps'}'
      else if (poolLengthMeters != null)
        '$poolLengthMeters m pool',
    ];
  }
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

/// Rest after a set, the same limits as the API (15 to 600 seconds).
abstract final class RestLimits {
  static const min = 15;
  static const max = 600;
  static const step = 15;
  static const defaultSeconds = 90;
}

/// "1:30", "45 s", "10:00".
String formatRest(int seconds) =>
    seconds < 60 ? '$seconds s' : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Limits from the API.
abstract final class SessionLimits {
  static const maxSetsPerExercise = 10;
  static const maxReps = 100;
  static const maxWeightKg = 500.0;
}
