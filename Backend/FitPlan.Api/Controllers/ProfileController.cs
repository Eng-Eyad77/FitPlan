using FitPlan.Api.DTOs.Profile;
using FitPlan.Api.Services.Profile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[Authorize]
[Route("api/profile")]
public class ProfileController(IProfileService profileService) : ApiControllerBase
{
    [HttpGet("me")]
    public async Task<IActionResult> GetUserProfile()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await profileService.GetUserProfileAsync(userId);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    [HttpPut("me")]
    public async Task<IActionResult> UpdateProfile(UpdateBioRequestDto updateProfileRequest)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await profileService.UpdateBioAsync(userId, updateProfileRequest);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    [HttpPost("me/picture")]
    public async Task<IActionResult> UploadProfilePicture(IFormFile file)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await profileService.UploadProfilePictureAsync(userId, file);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    [HttpDelete("me/picture")]
    public async Task<IActionResult> DeleteProfilePicture()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await profileService.DeleteProfilePictureAsync(userId);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }
}
