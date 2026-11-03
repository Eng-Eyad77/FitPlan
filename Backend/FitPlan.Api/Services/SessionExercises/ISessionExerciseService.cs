
using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.WorkoutSessions;

namespace FitPlan.Api.Services.SessionExercises;

public interface ISessionExerciseService
{
    Task<Result<SessionExerciseResponseDto>> AddExerciseAsync(Guid userId, Guid sessionId, AddSessionExerciseDto dto);

    Task<Result<bool>> RemoveExerciseAsync(Guid userId, Guid sessionId, Guid sessionExerciseId);

    Task<Result<SessionSetResponseDto>> AddSetAsync(Guid userId, Guid sessionId, Guid sessionExerciseId, SessionSetRequestDto dto);

    Task<Result<SessionSetResponseDto>> UpdateSetAsync(Guid userId, Guid sessionId, Guid sessionExerciseId, Guid setId, SessionSetRequestDto dto);

    Task<Result<bool>> DeleteSetAsync(Guid userId, Guid sessionId, Guid sessionExerciseId, Guid setId);
}
