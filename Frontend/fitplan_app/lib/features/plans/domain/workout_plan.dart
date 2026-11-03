import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_plan.freezed.dart';
part 'workout_plan.g.dart';

/// GET /api/workout-plans
@freezed
abstract class WorkoutPlan with _$WorkoutPlan {
  const factory WorkoutPlan({
    required String id,
    required String name,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int exerciseCount,
  }) = _WorkoutPlan;

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => _$WorkoutPlanFromJson(json);
}

/// GET /api/workout-plans/{id}/exercises
@freezed
abstract class PlanExercise with _$PlanExercise {
  const factory PlanExercise({
    required String id,
    required String exerciseId,
    required String name,
    required String gifUrl,
    required String bodyPart,
    @Default([]) List<String> instructions,
    required int sets,
    required int reps,
    required int order,
  }) = _PlanExercise;

  factory PlanExercise.fromJson(Map<String, dynamic> json) => _$PlanExerciseFromJson(json);
}

/// Limits from the API (AddWorkoutPlanExerciseDto).
abstract final class PlanLimits {
  static const maxSets = 4;
  static const maxReps = 20;
  static const nameLength = 100;
  static const descriptionLength = 500;
}
