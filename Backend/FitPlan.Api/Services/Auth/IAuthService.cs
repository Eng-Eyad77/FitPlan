using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.Auth;

namespace FitPlan.Api.Services.Auth;

public interface IAuthService
{
    Task<Result<bool>> SendSignUpCodeAsync(string email, string language);

    Task<Result<AuthResponseDto>> RegisterAsync(RegisterRequestDto request);

    Task<Result<AuthResponseDto>> LoginAsync(LoginRequestDto request);

    Task<Result<AuthResponseDto>> RefreshAsync(string refreshToken);

    Task LogoutAsync(string refreshToken);

    Task<Result<bool>> SendPasswordResetCodeAsync(string email, string language);

    Task<Result<AuthResponseDto>> ResetPasswordAsync(ResetPasswordRequestDto request);
}
