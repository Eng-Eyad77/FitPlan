// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutPlan _$WorkoutPlanFromJson(Map<String, dynamic> json) => _WorkoutPlan(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$WorkoutPlanToJson(_WorkoutPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'exerciseCount': instance.exerciseCount,
    };

_PlanExercise _$PlanExerciseFromJson(Map<String, dynamic> json) =>
    _PlanExercise(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      gifUrl: json['gifUrl'] as String,
      bodyPart: json['bodyPart'] as String,
      instructions:
          (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$PlanExerciseToJson(_PlanExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'name': instance.name,
      'gifUrl': instance.gifUrl,
      'bodyPart': instance.bodyPart,
      'instructions': instance.instructions,
      'sets': instance.sets,
      'reps': instance.reps,
      'order': instance.order,
    };
