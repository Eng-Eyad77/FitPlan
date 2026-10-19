using FitPlan.Api.DTOs.Auth;


namespace FitPlan.Api.Services.Auth;

public interface IAuthService
{
    Task<AuthResult> RegisterAsync(RegisterRequestDto request);

    Task<AuthResult> LoginAsync(LoginRequestDto request);

}
