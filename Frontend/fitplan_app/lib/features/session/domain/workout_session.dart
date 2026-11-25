import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../l10n/l10n.dart';

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
    /// The English name when [name] is in Arabic (Phase 11C), shown small under it.
    String? englishName,
    required String gifUrl,
    required String bodyPart,
    required int order,
    int? targetSets,
    int? targetReps,

    /// Rest after each set, in seconds. Null = the default (90 s).
    int? restSeconds,

    /// Copied from the plan; a change here goes back to the plan when the workout is finished.
    String? note,
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
        SuggestionReason.increaseWeight => l10n.whyIncrease,
        SuggestionReason.repeatWeight => l10n.whyRepeat,
        SuggestionReason.deload => l10n.whyDeload,
        SuggestionReason.moreReps => l10n.whyMoreReps,
      };
}

/// A detail a cardio machine can show. Same names and limits as the API (CardioFields, CardioEntryRequestDto).
enum CardioField {
  speed('speedKmh', min: 0.1, max: 30, decimal: true),
  incline('inclinePercent', min: 0, max: 40, decimal: true),
  distanceKm('distanceKm', min: 0.01, max: 100, decimal: true),
  distanceMeters('distanceMeters', min: 1, max: 50000),
  level('level', min: 1, max: 30),
  damper('level', min: 1, max: 10), // the rower's "level"
  floors('floors', min: 1, max: 1000),
  cadence('cadenceRpm', min: 20, max: 200),
  strokeRate('strokeRate', min: 10, max: 60),
  poolLength('poolLengthMeters', min: 10, max: 100),
  laps('laps', min: 1, max: 2000);

  const CardioField(this.jsonKey, {required this.min, required this.max, this.decimal = false});

  final String jsonKey;

  String get label => switch (this) {
        speed => l10n.cfSpeed,
        incline => l10n.cfIncline,
        distanceKm || distanceMeters => l10n.cfDistance,
        level => l10n.cfLevel,
        damper => l10n.cfDamper,
        floors => l10n.cfFloors,
        cadence => l10n.cfCadence,
        strokeRate => l10n.cfStrokeRate,
        poolLength => l10n.cfPoolLength,
        laps => l10n.cfLaps,
      };

  String get unit => switch (this) {
        speed => l10n.unitKmh,
        incline => '%',
        distanceKm => l10n.unitKm,
        distanceMeters || poolLength => l10n.unitM,
        cadence => 'rpm',
        strokeRate => 'spm',
        level || damper || floors || laps => '',
      };
  final num min;
  final num max;
  final bool decimal;

  /// "Speed: 0.1 to 30 km/h"
  String get rangeText => l10n.cardioRange(label, _n(min), _n(max), unit.isEmpty ? '' : ' $unit');

  static String _n(num v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';
}

enum CardioMachine {
  @JsonValue('Treadmill')
  treadmill([CardioField.speed, CardioField.incline, CardioField.distanceKm]),
  @JsonValue('StairClimber')
  stairClimber([CardioField.level, CardioField.floors]),
  @JsonValue('StationaryBike')
  stationaryBike([CardioField.level, CardioField.distanceKm, CardioField.cadence]),
  @JsonValue('Elliptical')
  elliptical([CardioField.level, CardioField.distanceKm, CardioField.incline]),
  @JsonValue('Rower')
  rower([CardioField.distanceMeters, CardioField.damper, CardioField.strokeRate]),
  @JsonValue('Swimming')
  swimming([CardioField.distanceMeters, CardioField.poolLength, CardioField.laps]),

  /// Kept for entries saved before it was retired; it can't be picked.
  @JsonValue('Other')
  other([CardioField.speed, CardioField.incline, CardioField.distanceKm], selectable: false),

  /// A machine this version doesn't know yet (added by a newer server). Shown as plain cardio.
  unknown([], selectable: false);

  const CardioMachine(this.fields, {this.selectable = true});

  String get label => switch (this) {
        treadmill => l10n.cmTreadmill,
        stairClimber => l10n.cmStairs,
        stationaryBike => l10n.cmBike,
        elliptical => l10n.cmElliptical,
        rower => l10n.cmRower,
        swimming => l10n.cmSwimming,
        other => l10n.cmOther,
        unknown => l10n.cardio,
      };

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
      if (speedKmh != null) l10n.cdSpeed(n(speedKmh!)),
      if (inclinePercent != null) l10n.cdIncline(n(inclinePercent!)),
      if (distanceKm != null) l10n.cdKm(n(distanceKm!)),
      if (distanceMeters != null) l10n.cdMeters(distanceMeters!),
      if (level != null) machine == CardioMachine.rower ? l10n.cdDamper(level!) : l10n.cdLevel(level!),
      if (floors != null) l10n.cdFloors(floors!),
      if (cadenceRpm != null) '$cadenceRpm rpm',
      if (strokeRate != null) '$strokeRate spm',
      if (laps != null && poolLengthMeters != null)
        l10n.cdLapsOf(laps!, poolLengthMeters!)
      else if (laps != null)
        l10n.cdLaps(laps!)
      else if (poolLengthMeters != null)
        l10n.cdPool(poolLengthMeters!),
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
    // only when finishing: the lifetime-volume milestones this workout crossed (Phase 10)
    @Default([]) List<String> newMilestones,
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
    seconds < 60 ? l10n.secondsShort(seconds) : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Limits from the API.
abstract final class SessionLimits {
  static const maxSetsPerExercise = 10;
  static const maxReps = 100;
  static const maxWeightKg = 500.0;
}
