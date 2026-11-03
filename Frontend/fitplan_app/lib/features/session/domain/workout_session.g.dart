// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    _WorkoutSession(
      id: json['id'] as String,
      name: json['name'] as String,
      workoutPlanId: json['workoutPlanId'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => SessionExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cardio:
          (json['cardio'] as List<dynamic>?)
              ?.map((e) => CardioEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkoutSessionToJson(_WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'workoutPlanId': instance.workoutPlanId,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'notes': instance.notes,
      'exercises': instance.exercises,
      'cardio': instance.cardio,
    };

_SessionExercise _$SessionExerciseFromJson(Map<String, dynamic> json) =>
    _SessionExercise(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      gifUrl: json['gifUrl'] as String,
      bodyPart: json['bodyPart'] as String,
      order: (json['order'] as num).toInt(),
      targetSets: (json['targetSets'] as num?)?.toInt(),
      targetReps: (json['targetReps'] as num?)?.toInt(),
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((e) => SessionSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastPerformance: json['lastPerformance'] == null
          ? null
          : LastPerformance.fromJson(
              json['lastPerformance'] as Map<String, dynamic>,
            ),
      suggestion: json['suggestion'] == null
          ? null
          : Suggestion.fromJson(json['suggestion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionExerciseToJson(_SessionExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'name': instance.name,
      'gifUrl': instance.gifUrl,
      'bodyPart': instance.bodyPart,
      'order': instance.order,
      'targetSets': instance.targetSets,
      'targetReps': instance.targetReps,
      'sets': instance.sets,
      'lastPerformance': instance.lastPerformance,
      'suggestion': instance.suggestion,
    };

_SessionSet _$SessionSetFromJson(Map<String, dynamic> json) => _SessionSet(
  id: json['id'] as String,
  setNumber: (json['setNumber'] as num).toInt(),
  reps: (json['reps'] as num).toInt(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SessionSetToJson(_SessionSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'setNumber': instance.setNumber,
      'reps': instance.reps,
      'weightKg': instance.weightKg,
    };

_LastPerformance _$LastPerformanceFromJson(Map<String, dynamic> json) =>
    _LastPerformance(
      performedAt: DateTime.parse(json['performedAt'] as String),
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((e) => SessionSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LastPerformanceToJson(_LastPerformance instance) =>
    <String, dynamic>{
      'performedAt': instance.performedAt.toIso8601String(),
      'sets': instance.sets,
    };

_Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => _Suggestion(
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  reps: (json['reps'] as num).toInt(),
  reason: $enumDecode(_$SuggestionReasonEnumMap, json['reason']),
);

Map<String, dynamic> _$SuggestionToJson(_Suggestion instance) =>
    <String, dynamic>{
      'weightKg': instance.weightKg,
      'reps': instance.reps,
      'reason': _$SuggestionReasonEnumMap[instance.reason]!,
    };

const _$SuggestionReasonEnumMap = {
  SuggestionReason.increaseWeight: 'IncreaseWeight',
  SuggestionReason.repeatWeight: 'RepeatWeight',
  SuggestionReason.deload: 'Deload',
  SuggestionReason.moreReps: 'MoreReps',
};

_CardioEntry _$CardioEntryFromJson(Map<String, dynamic> json) => _CardioEntry(
  id: json['id'] as String,
  machine: $enumDecode(_$CardioMachineEnumMap, json['machine']),
  durationSeconds: (json['durationSeconds'] as num).toInt(),
  speedKmh: (json['speedKmh'] as num?)?.toDouble(),
  inclinePercent: (json['inclinePercent'] as num?)?.toDouble(),
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  estimatedCalories: (json['estimatedCalories'] as num?)?.toInt(),
);

Map<String, dynamic> _$CardioEntryToJson(_CardioEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'machine': _$CardioMachineEnumMap[instance.machine]!,
      'durationSeconds': instance.durationSeconds,
      'speedKmh': instance.speedKmh,
      'inclinePercent': instance.inclinePercent,
      'distanceKm': instance.distanceKm,
      'estimatedCalories': instance.estimatedCalories,
    };

const _$CardioMachineEnumMap = {
  CardioMachine.treadmill: 'Treadmill',
  CardioMachine.stationaryBike: 'StationaryBike',
  CardioMachine.elliptical: 'Elliptical',
  CardioMachine.stairClimber: 'StairClimber',
  CardioMachine.rower: 'Rower',
  CardioMachine.other: 'Other',
};

_SessionSummary _$SessionSummaryFromJson(Map<String, dynamic> json) =>
    _SessionSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      exerciseCount: (json['exerciseCount'] as num).toInt(),
      setCount: (json['setCount'] as num).toInt(),
      totalVolumeKg: (json['totalVolumeKg'] as num).toDouble(),
      cardioDurationSeconds: (json['cardioDurationSeconds'] as num).toInt(),
      estimatedCalories: (json['estimatedCalories'] as num).toInt(),
    );

Map<String, dynamic> _$SessionSummaryToJson(_SessionSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'exerciseCount': instance.exerciseCount,
      'setCount': instance.setCount,
      'totalVolumeKg': instance.totalVolumeKg,
      'cardioDurationSeconds': instance.cardioDurationSeconds,
      'estimatedCalories': instance.estimatedCalories,
    };
