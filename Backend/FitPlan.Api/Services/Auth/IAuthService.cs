using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.Auth;


namespace FitPlan.Api.Services.Auth;

public interface IAuthService
{
    Task<Result<AuthResponseDto>> RegisterAsync(RegisterRequestDto request);

    Task<Result<AuthResponseDto>> LoginAsync(LoginRequestDto request);

}
