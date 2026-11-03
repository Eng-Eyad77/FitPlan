
using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.BodyWeight;

namespace FitPlan.Api.Services.BodyWeight;

public interface IBodyWeightService
{
    Task<Result<BodyWeightEntryResponseDto>> AddEntryAsync(Guid userId, AddBodyWeightDto dto);

    Task<BodyWeightEntryResponseDto[]> GetHistoryAsync(Guid userId);

    Task<Result<bool>> DeleteEntryAsync(Guid userId, Guid id);

    Task<decimal?> GetCurrentWeightAsync(Guid userId);
}
