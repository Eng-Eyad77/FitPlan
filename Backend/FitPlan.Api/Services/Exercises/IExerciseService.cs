
using FitPlan.Api.DTOs.Exercises;

namespace FitPlan.Api.Services.Exercises;

public interface IExerciseService
{
    Task<ExerciseListResponseDto> GetAllExercisesAsync(
        int page,
        int pageSize,
        string? bodyPart,
        string? search);

    Task<ExerciseDto?> GetExerciseByIdAsync(string id);
}
