
using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.WorkoutSessions;

namespace FitPlan.Api.Services.CardioEntries;

public interface ICardioEntryService
{
    Task<Result<CardioEntryResponseDto>> AddCardioAsync(Guid userId, Guid sessionId, CardioEntryRequestDto dto);

    Task<Result<CardioEntryResponseDto>> UpdateCardioAsync(Guid userId, Guid sessionId, Guid id, CardioEntryRequestDto dto);

    Task<Result<bool>> DeleteCardioAsync(Guid userId, Guid sessionId, Guid id);
}
