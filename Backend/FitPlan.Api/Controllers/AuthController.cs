using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Services.Auth;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[Route("api/auth")]
public class AuthController(IAuthService authService) : ApiControllerBase
{
    [HttpPost("register")]
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
    public async Task<IActionResult> Login(LoginRequestDto newLogin)
    {
        var result = await authService.LoginAsync(newLogin);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }
}
