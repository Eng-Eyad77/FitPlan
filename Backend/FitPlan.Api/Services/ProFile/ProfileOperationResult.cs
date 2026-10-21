
namespace FitPlan.Api.Services.Profile;

public record ProfileOperationResult<T>(
    bool Succeeded,
    T? Data,
    string? ErrorCode);
