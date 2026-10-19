using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Services.Auth;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService authService;  



    public AuthController(IAuthService authService)
    {
        this.authService = authService;
    } 



    [HttpPost("register")]
    public async Task<ActionResult> CreateUser(RegisterRequestDto newRegister)
    {
        var newUser =  await authService.RegisterAsync(newRegister);

        if(newUser.Succeeded == false)
        {
            return Conflict(new
            {
                newUser.ErrorCode
            });
        }


        return StatusCode(201, newUser.Data);

        
    }


    [HttpPost("login")]

    public async Task<ActionResult> Login(LoginRequestDto newLogin)
    {
        var newLoginAttempt = await authService.LoginAsync(newLogin);

        if (!newLoginAttempt.Succeeded)
        {
            return Unauthorized(new
            {
                newLoginAttempt.ErrorCode
            }); 
        }

        return Ok(newLoginAttempt.Data);
    }


}
