using FitPlan.Api.DTOs.Auth;


namespace FitPlan.Api.Services.Auth;

public interface IAuthService
{
    Task<RegisterResult> RegisterAsync(RegisterRequestDto request);

}
