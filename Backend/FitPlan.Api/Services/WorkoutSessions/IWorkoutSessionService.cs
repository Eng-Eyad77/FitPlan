
using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.Common;
using FitPlan.Api.DTOs.WorkoutSessions;

namespace FitPlan.Api.Services.WorkoutSessions;

public interface IWorkoutSessionService
{
    Task<Result<WorkoutSessionResponseDto>> StartSessionAsync(Guid userId, StartWorkoutSessionDto dto);

    Task<Result<WorkoutSessionResponseDto>> GetActiveSessionAsync(Guid userId);

    Task<Result<WorkoutSessionResponseDto>> GetSessionByIdAsync(Guid userId, Guid id);

    Task<PagedResponseDto<WorkoutSessionSummaryDto>> GetHistoryAsync(Guid userId, int page, int pageSize);

    Task<Result<WorkoutSessionSummaryDto>> CompleteSessionAsync(Guid userId, Guid id, CompleteWorkoutSessionDto dto);

    Task<Result<bool>> DeleteSessionAsync(Guid userId, Guid id);
}
