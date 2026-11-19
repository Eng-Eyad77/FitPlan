using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Services.Auth;
using FitPlan.Api.Extensions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace FitPlan.Api.Controllers;

[Route("api/auth")]
public class AuthController(IAuthService authService) : ApiControllerBase
{
    [HttpPost("register")]
    [EnableRateLimiting(RateLimitingExtensions.SignInPolicy)]
    public async Task<IActionResult> CreateUser(RegisterRequestDto newRegister)
    {
        var result = await authService.RegisterAsync(newRegister);

        if (!result.IsSuccess)
        {
            return Problem(result.Error);
        }

        return StatusCode(StatusCodes.Status201Created, result.Data);
    }


    [HttpPost("login")]
    [EnableRateLimiting(RateLimitingExtensions.SignInPolicy)]
    public async Task<IActionResult> Login(LoginRequestDto newLogin)
    {
        var result = await authService.LoginAsync(newLogin);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }

    // Swaps a refresh token for a new access token and a new refresh token. The old one stops working.
    [HttpPost("refresh")]
    [EnableRateLimiting(RateLimitingExtensions.RefreshPolicy)]
    public async Task<IActionResult> Refresh(RefreshRequestDto request)
    {
        var result = await authService.RefreshAsync(request.RefreshToken);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }

    // A forgotten password, proved with the recovery code. Shares the sign-in limit against guessing.
    [HttpPost("reset-password")]
    [EnableRateLimiting(RateLimitingExtensions.SignInPolicy)]
    public async Task<IActionResult> ResetPassword(ResetPasswordRequestDto request)
    {
        var result = await authService.ResetPasswordAsync(request);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }

    // Ends this login on the server: its refresh tokens stop working.
    [HttpPost("logout")]
    [EnableRateLimiting(RateLimitingExtensions.RefreshPolicy)]
    public async Task<IActionResult> Logout(RefreshRequestDto request)
    {
        await authService.LogoutAsync(request.RefreshToken);

        return NoContent();
    }
}
