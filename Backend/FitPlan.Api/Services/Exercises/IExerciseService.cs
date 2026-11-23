
using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.Exercises;

namespace FitPlan.Api.Services.Exercises;

public interface IExerciseService
{
    Task<ExerciseListResponseDto> GetAllExercisesAsync(
        int page,
        int pageSize,
        string? bodyPart,
        string? search,
        string language = ContentLanguage.English);

    Task<IReadOnlyList<string>> GetBodyPartsAsync();

    Task<Result<ExerciseDto>> GetExerciseByIdAsync(string id, string language = ContentLanguage.English);
}
