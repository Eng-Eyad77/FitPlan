// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StatsOverview _$StatsOverviewFromJson(Map<String, dynamic> json) =>
    _StatsOverview(
      weeklyGoal: (json['weeklyGoal'] as num?)?.toInt(),
      currentStreakWeeks: (json['currentStreakWeeks'] as num).toInt(),
      totalWorkouts: (json['totalWorkouts'] as num).toInt(),
      thisWeek: WeekStats.fromJson(json['thisWeek'] as Map<String, dynamic>),
      lastWeek: WeekStats.fromJson(json['lastWeek'] as Map<String, dynamic>),
      weeks:
          (json['weeks'] as List<dynamic>?)
              ?.map((e) => WeekStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StatsOverviewToJson(_StatsOverview instance) =>
    <String, dynamic>{
      'weeklyGoal': instance.weeklyGoal,
      'currentStreakWeeks': instance.currentStreakWeeks,
      'totalWorkouts': instance.totalWorkouts,
      'thisWeek': instance.thisWeek,
      'lastWeek': instance.lastWeek,
      'weeks': instance.weeks,
    };

_WeekStats _$WeekStatsFromJson(Map<String, dynamic> json) => _WeekStats(
  weekStart: DateTime.parse(json['weekStart'] as String),
  workouts: (json['workouts'] as num).toInt(),
  sets: (json['sets'] as num).toInt(),
  volumeKg: (json['volumeKg'] as num).toDouble(),
  cardioSeconds: (json['cardioSeconds'] as num).toInt(),
  estimatedCalories: (json['estimatedCalories'] as num).toInt(),
);

Map<String, dynamic> _$WeekStatsToJson(_WeekStats instance) =>
    <String, dynamic>{
      'weekStart': instance.weekStart.toIso8601String(),
      'workouts': instance.workouts,
      'sets': instance.sets,
      'volumeKg': instance.volumeKg,
      'cardioSeconds': instance.cardioSeconds,
      'estimatedCalories': instance.estimatedCalories,
    };

_ExerciseRecords _$ExerciseRecordsFromJson(Map<String, dynamic> json) =>
    _ExerciseRecords(
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      gifUrl: json['gifUrl'] as String,
      bodyPart: json['bodyPart'] as String,
      lastPerformedAt: DateTime.parse(json['lastPerformedAt'] as String),
      sessionCount: (json['sessionCount'] as num).toInt(),
      heaviestWeight: json['heaviestWeight'] == null
          ? null
          : RecordSet.fromJson(json['heaviestWeight'] as Map<String, dynamic>),
      bestEstimated1Rm: json['bestEstimated1Rm'] == null
          ? null
          : RecordSet.fromJson(
              json['bestEstimated1Rm'] as Map<String, dynamic>,
            ),
      mostReps: RecordSet.fromJson(json['mostReps'] as Map<String, dynamic>),
      bestSetVolume: json['bestSetVolume'] == null
          ? null
          : RecordSet.fromJson(json['bestSetVolume'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExerciseRecordsToJson(_ExerciseRecords instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'name': instance.name,
      'gifUrl': instance.gifUrl,
      'bodyPart': instance.bodyPart,
      'lastPerformedAt': instance.lastPerformedAt.toIso8601String(),
      'sessionCount': instance.sessionCount,
      'heaviestWeight': instance.heaviestWeight,
      'bestEstimated1Rm': instance.bestEstimated1Rm,
      'mostReps': instance.mostReps,
      'bestSetVolume': instance.bestSetVolume,
    };

_RecordSet _$RecordSetFromJson(Map<String, dynamic> json) => _RecordSet(
  value: (json['value'] as num).toDouble(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  reps: (json['reps'] as num).toInt(),
  sessionId: json['sessionId'] as String,
  achievedAt: DateTime.parse(json['achievedAt'] as String),
);

Map<String, dynamic> _$RecordSetToJson(_RecordSet instance) =>
    <String, dynamic>{
      'value': instance.value,
      'weightKg': instance.weightKg,
      'reps': instance.reps,
      'sessionId': instance.sessionId,
      'achievedAt': instance.achievedAt.toIso8601String(),
    };

_ExerciseProgress _$ExerciseProgressFromJson(
  Map<String, dynamic> json,
) => _ExerciseProgress(
  records: ExerciseRecords.fromJson(json['records'] as Map<String, dynamic>),
  sessions:
      (json['sessions'] as List<dynamic>?)
          ?.map((e) => ExerciseSessionPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ExerciseProgressToJson(_ExerciseProgress instance) =>
    <String, dynamic>{
      'records': instance.records,
      'sessions': instance.sessions,
    };

_ExerciseSessionPoint _$ExerciseSessionPointFromJson(
  Map<String, dynamic> json,
) => _ExerciseSessionPoint(
  sessionId: json['sessionId'] as String,
  performedAt: DateTime.parse(json['performedAt'] as String),
  topSetWeightKg: (json['topSetWeightKg'] as num?)?.toDouble(),
  topSetReps: (json['topSetReps'] as num).toInt(),
  estimated1Rm: (json['estimated1Rm'] as num?)?.toDouble(),
  volumeKg: (json['volumeKg'] as num).toDouble(),
  sets: (json['sets'] as num).toInt(),
);

Map<String, dynamic> _$ExerciseSessionPointToJson(
  _ExerciseSessionPoint instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'performedAt': instance.performedAt.toIso8601String(),
  'topSetWeightKg': instance.topSetWeightKg,
  'topSetReps': instance.topSetReps,
  'estimated1Rm': instance.estimated1Rm,
  'volumeKg': instance.volumeKg,
  'sets': instance.sets,
};

_SessionComparison _$SessionComparisonFromJson(
  Map<String, dynamic> json,
) => _SessionComparison(
  sessionId: json['sessionId'] as String,
  previousSessionId: json['previousSessionId'] as String?,
  previousPerformedAt: json['previousPerformedAt'] == null
      ? null
      : DateTime.parse(json['previousPerformedAt'] as String),
  volumeKg: ComparedValue.fromJson(json['volumeKg'] as Map<String, dynamic>),
  sets: ComparedValue.fromJson(json['sets'] as Map<String, dynamic>),
  durationSeconds: ComparedValue.fromJson(
    json['durationSeconds'] as Map<String, dynamic>,
  ),
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => ExerciseComparison.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  newRecords:
      (json['newRecords'] as List<dynamic>?)
          ?.map((e) => NewRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SessionComparisonToJson(_SessionComparison instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'previousSessionId': instance.previousSessionId,
      'previousPerformedAt': instance.previousPerformedAt?.toIso8601String(),
      'volumeKg': instance.volumeKg,
      'sets': instance.sets,
      'durationSeconds': instance.durationSeconds,
      'exercises': instance.exercises,
      'newRecords': instance.newRecords,
    };

_ComparedValue _$ComparedValueFromJson(Map<String, dynamic> json) =>
    _ComparedValue(
      current: (json['current'] as num).toDouble(),
      previous: (json['previous'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ComparedValueToJson(_ComparedValue instance) =>
    <String, dynamic>{
      'current': instance.current,
      'previous': instance.previous,
    };

_ExerciseComparison _$ExerciseComparisonFromJson(Map<String, dynamic> json) =>
    _ExerciseComparison(
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      topSetWeightKg: (json['topSetWeightKg'] as num?)?.toDouble(),
      topSetReps: (json['topSetReps'] as num).toInt(),
      previousTopSetWeightKg: (json['previousTopSetWeightKg'] as num?)
          ?.toDouble(),
      previousTopSetReps: (json['previousTopSetReps'] as num?)?.toInt(),
      volumeKg: (json['volumeKg'] as num).toDouble(),
      previousVolumeKg: (json['previousVolumeKg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ExerciseComparisonToJson(_ExerciseComparison instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'name': instance.name,
      'topSetWeightKg': instance.topSetWeightKg,
      'topSetReps': instance.topSetReps,
      'previousTopSetWeightKg': instance.previousTopSetWeightKg,
      'previousTopSetReps': instance.previousTopSetReps,
      'volumeKg': instance.volumeKg,
      'previousVolumeKg': instance.previousVolumeKg,
    };

_NewRecord _$NewRecordFromJson(Map<String, dynamic> json) => _NewRecord(
  exerciseId: json['exerciseId'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$RecordTypeEnumMap, json['type']),
  value: (json['value'] as num).toDouble(),
  previousBest: (json['previousBest'] as num).toDouble(),
);

Map<String, dynamic> _$NewRecordToJson(_NewRecord instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'name': instance.name,
      'type': _$RecordTypeEnumMap[instance.type]!,
      'value': instance.value,
      'previousBest': instance.previousBest,
    };

const _$RecordTypeEnumMap = {
  RecordType.heaviestWeight: 'HeaviestWeight',
  RecordType.estimated1Rm: 'Estimated1Rm',
  RecordType.mostReps: 'MostReps',
  RecordType.bestSetVolume: 'BestSetVolume',
};

_BodyWeightEntry _$BodyWeightEntryFromJson(Map<String, dynamic> json) =>
    _BodyWeightEntry(
      id: json['id'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );

Map<String, dynamic> _$BodyWeightEntryToJson(_BodyWeightEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weightKg': instance.weightKg,
      'recordedAt': instance.recordedAt.toIso8601String(),
    };
