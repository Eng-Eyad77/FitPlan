using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.Stats;

namespace FitPlan.Api.Services.Stats;

public interface IStatsService
{
    Task<Result<StatsOverviewDto>> GetOverviewAsync(Guid userId, StatsOverviewQuery query);

    Task<ExerciseRecordsDto[]> GetRecordsAsync(Guid userId);

    Task<Result<ExerciseProgressDto>> GetExerciseProgressAsync(Guid userId, string exerciseId);

    Task<Result<SessionComparisonDto>> GetSessionComparisonAsync(Guid userId, Guid sessionId);
}
