using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.WorkoutPlanExercises;

namespace FitPlan.Api.Services.WorkoutPlanExercises;

public interface IWorkoutPlanExerciseService
{
    Task<Result<WorkoutPlanExerciseResponseDto>> AddExerciseToPlanAsync(
        Guid userId,
        Guid planId,
        AddWorkoutPlanExerciseDto  dto);

    Task<Result<WorkoutPlanExerciseResponseDto[]>> GetPlanExercisesAsync(
        Guid userId,
        Guid planId);

    Task<Result<WorkoutPlanExerciseResponseDto>> UpdatePlanExerciseAsync(
        Guid userId,
        Guid planId,
        Guid id,
        UpdateWorkoutPlanExerciseDto UpdateWorkoutPlanExercise);

    Task<Result<bool>> RemoveExerciseFromPlanAsync(
        Guid userId,
        Guid planId,
        Guid id);
}