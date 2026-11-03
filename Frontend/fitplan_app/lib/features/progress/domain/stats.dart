import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats.freezed.dart';
part 'stats.g.dart';

/// GET /api/stats/overview
@freezed
abstract class StatsOverview with _$StatsOverview {
  const factory StatsOverview({
    int? weeklyGoal,
    required int currentStreakWeeks,
    required int totalWorkouts,
    required WeekStats thisWeek,
    required WeekStats lastWeek,
    @Default([]) List<WeekStats> weeks,
  }) = _StatsOverview;

  factory StatsOverview.fromJson(Map<String, dynamic> json) => _$StatsOverviewFromJson(json);
}

@freezed
abstract class WeekStats with _$WeekStats {
  const factory WeekStats({
    required DateTime weekStart,
    required int workouts,
    required int sets,
    required double volumeKg,
    required int cardioSeconds,
    required int estimatedCalories,
  }) = _WeekStats;

  factory WeekStats.fromJson(Map<String, dynamic> json) => _$WeekStatsFromJson(json);
}

/// GET /api/stats/records (one item per exercise)
@freezed
abstract class ExerciseRecords with _$ExerciseRecords {
  const factory ExerciseRecords({
    required String exerciseId,
    required String name,
    required String gifUrl,
    required String bodyPart,
    required DateTime lastPerformedAt,
    required int sessionCount,
    RecordSet? heaviestWeight,
    RecordSet? bestEstimated1Rm,
    required RecordSet mostReps,
    RecordSet? bestSetVolume,
  }) = _ExerciseRecords;

  factory ExerciseRecords.fromJson(Map<String, dynamic> json) => _$ExerciseRecordsFromJson(json);
}

/// The set that holds a record, and the record value.
@freezed
abstract class RecordSet with _$RecordSet {
  const factory RecordSet({
    required double value,
    double? weightKg,
    required int reps,
    required String sessionId,
    required DateTime achievedAt,
  }) = _RecordSet;

  factory RecordSet.fromJson(Map<String, dynamic> json) => _$RecordSetFromJson(json);
}

/// GET /api/stats/exercises/{id}
@freezed
abstract class ExerciseProgress with _$ExerciseProgress {
  const factory ExerciseProgress({
    required ExerciseRecords records,
    @Default([]) List<ExerciseSessionPoint> sessions,
  }) = _ExerciseProgress;

  factory ExerciseProgress.fromJson(Map<String, dynamic> json) => _$ExerciseProgressFromJson(json);
}

@freezed
abstract class ExerciseSessionPoint with _$ExerciseSessionPoint {
  const factory ExerciseSessionPoint({
    required String sessionId,
    required DateTime performedAt,
    double? topSetWeightKg,
    required int topSetReps,
    double? estimated1Rm,
    required double volumeKg,
    required int sets,
  }) = _ExerciseSessionPoint;

  factory ExerciseSessionPoint.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSessionPointFromJson(json);
}

/// GET /api/stats/sessions/{id}/comparison
@freezed
abstract class SessionComparison with _$SessionComparison {
  const factory SessionComparison({
    required String sessionId,
    String? previousSessionId,
    DateTime? previousPerformedAt,
    required ComparedValue volumeKg,
    required ComparedValue sets,
    required ComparedValue durationSeconds,
    @Default([]) List<ExerciseComparison> exercises,
    @Default([]) List<NewRecord> newRecords,
  }) = _SessionComparison;

  factory SessionComparison.fromJson(Map<String, dynamic> json) =>
      _$SessionComparisonFromJson(json);
}

@freezed
abstract class ComparedValue with _$ComparedValue {
  const ComparedValue._();

  const factory ComparedValue({required double current, double? previous}) = _ComparedValue;

  factory ComparedValue.fromJson(Map<String, dynamic> json) => _$ComparedValueFromJson(json);

  /// +6.0 for 6% more than last time. Null without a previous value (or when it was 0).
  double? get percentChange =>
      previous == null || previous == 0 ? null : (current - previous!) / previous! * 100;
}

@freezed
abstract class ExerciseComparison with _$ExerciseComparison {
  const factory ExerciseComparison({
    required String exerciseId,
    required String name,
    double? topSetWeightKg,
    required int topSetReps,
    double? previousTopSetWeightKg,
    int? previousTopSetReps,
    required double volumeKg,
    double? previousVolumeKg,
  }) = _ExerciseComparison;

  factory ExerciseComparison.fromJson(Map<String, dynamic> json) =>
      _$ExerciseComparisonFromJson(json);
}

enum RecordType {
  @JsonValue('HeaviestWeight')
  heaviestWeight('Heaviest weight'),
  @JsonValue('Estimated1Rm')
  estimated1Rm('Estimated 1RM'),
  @JsonValue('MostReps')
  mostReps('Most reps'),
  @JsonValue('BestSetVolume')
  bestSetVolume('Best set volume');

  const RecordType(this.label);

  final String label;
}

@freezed
abstract class NewRecord with _$NewRecord {
  const factory NewRecord({
    required String exerciseId,
    required String name,
    required RecordType type,
    required double value,
    required double previousBest,
  }) = _NewRecord;

  factory NewRecord.fromJson(Map<String, dynamic> json) => _$NewRecordFromJson(json);
}

/// GET /api/body-weight (newest first)
@freezed
abstract class BodyWeightEntry with _$BodyWeightEntry {
  const factory BodyWeightEntry({
    required String id,
    required double weightKg,
    required DateTime recordedAt,
  }) = _BodyWeightEntry;

  factory BodyWeightEntry.fromJson(Map<String, dynamic> json) => _$BodyWeightEntryFromJson(json);
}
