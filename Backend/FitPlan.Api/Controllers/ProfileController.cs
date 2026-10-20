using System.Security.Claims;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Profile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;


namespace FitPlan.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/profile")]
public class ProfileController(FitPlanDbContext context) : ControllerBase
{

    [HttpGet("me")]

    public async Task<IActionResult> GetUserProfile()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;


        if (Guid.TryParse(userId, out var result))
        {
            var user = await context.Users.FirstOrDefaultAsync(u => u.Id == result);
            if (user is null)
            {
                return Unauthorized();
            }

            return Ok(new ProfileDto
            {
                Id = user.Id,
                Username = user.Username,
                Bio = user.Bio,
                ProfilePictureUrl = user.ProfilePictureUrl,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt
            }
            );
        }
        else
        {
            return Unauthorized();
        }

    }




    [HttpPut("me")]
    public async Task<IActionResult> UpdateProfile(UpdateProfileRequestDto updateProfileRequest)
    {


        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;


        if (Guid.TryParse(userId, out var result))
        {
            var user = await context.Users.FirstOrDefaultAsync(u => u.Id == result);
            if (user is null)
            {
                return Unauthorized();
            }

            if (updateProfileRequest.Bio != user.Bio)
            {

                user.Bio = updateProfileRequest.Bio;
                user.UpdatedAt = DateTime.UtcNow;
                await context.SaveChangesAsync();

            }



            return Ok(new ProfileDto
            {
                Id = user.Id,
                Username = user.Username,
                Bio = user.Bio,
                ProfilePictureUrl = user.ProfilePictureUrl,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt
            });
        }
        else
        {
            return Unauthorized();
        }
    }




}
