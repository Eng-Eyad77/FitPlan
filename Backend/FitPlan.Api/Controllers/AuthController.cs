using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Services.Auth;
using FitPlan.Api.Extensions;
using FitPlan.Api.Services.Exercises;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace FitPlan.Api.Controllers;

[Route("api/auth")]
public class AuthController(IAuthService authService) : ApiControllerBase
{
    // Step 1 of sign-up (D18). 202 for every address: a registered one gets a notice, not a code.
    [HttpPost("register/code")]
    [EnableRateLimiting(RateLimitingExtensions.SignInPolicy)]
    public async Task<IActionResult> SendSignUpCode(EmailRequestDto request)
    {
        var result = await authService.SendSignUpCodeAsync(request.Email, ContentLanguage.From(Request));

        return result.IsSuccess ? Accepted() : Problem(result.Error);
    }

    // Step 2: the code with the username and password creates the account.
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

    // A forgotten password, step 1. 202 for every address, so it never shows which ones are registered.
    [HttpPost("password-reset/code")]
    [EnableRateLimiting(RateLimitingExtensions.SignInPolicy)]
    public async Task<IActionResult> SendPasswordResetCode(EmailRequestDto request)
    {
        var result = await authService.SendPasswordResetCodeAsync(request.Email, ContentLanguage.From(Request));

        return result.IsSuccess ? Accepted() : Problem(result.Error);
    }

    // Step 2: is the emailed code right? 204 if so. Nothing changes, but it counts as an attempt.
    [HttpPost("password-reset/check")]
    [EnableRateLimiting(RateLimitingExtensions.SignInPolicy)]
    public async Task<IActionResult> CheckPasswordResetCode(ResetCodeCheckDto request)
    {
        var result = await authService.CheckPasswordResetCodeAsync(request);

        return result.IsSuccess ? NoContent() : Problem(result.Error);
    }

    // Step 3: the emailed code and the new password. Shares the sign-in limit against guessing.
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
