using FitPlan.Api.DTOs.Profile;
using FitPlan.Api.Extensions;
using FitPlan.Api.Services.Exercises;
using FitPlan.Api.Services.Profile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

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


    [HttpPut("me/weekly-goal")]
    public async Task<IActionResult> UpdateWeeklyGoal(UpdateWeeklyGoalDto updateWeeklyGoalRequest)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await profileService.UpdateWeeklyGoalAsync(userId, updateWeeklyGoalRequest);

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


    // D12: only the signed-in owner can see their picture. The file name changes with each upload,
    // so the app can cache it by the profile's ProfilePictureUrl.
    [HttpGet("me/picture")]
    public async Task<IActionResult> GetProfilePicture()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await profileService.GetProfilePictureAsync(userId);
        if (!result.IsSuccess)
        {
            return Problem(result.Error);
        }

        Response.Headers.CacheControl = "private, max-age=86400";
        return PhysicalFile(result.Data.Path, result.Data.ContentType);
    }


    // D18 step 1: the current password, and a code to the new address. Shares the sign-in limit against guessing.
    [HttpPost("me/email/code")]
    [EnableRateLimiting(RateLimitingExtensions.SignInPolicy)]
    public async Task<IActionResult> SendEmailChangeCode(ChangeEmailRequestDto request)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await profileService.SendEmailChangeCodeAsync(userId, request, ContentLanguage.From(Request));

        return result.IsSuccess ? Accepted() : Problem(result.Error);
    }


    // Step 2: the code changes the email.
    [HttpPut("me/email")]
    [EnableRateLimiting(RateLimitingExtensions.SignInPolicy)]
    public async Task<IActionResult> ConfirmEmailChange(ConfirmEmailChangeDto request)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await profileService.ConfirmEmailChangeAsync(userId, request, ContentLanguage.From(Request));

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    // F-02. POST, not DELETE, because it carries the password in its body.
    [HttpPost("me/delete")]
    [EnableRateLimiting(RateLimitingExtensions.SignInPolicy)]
    public async Task<IActionResult> DeleteAccount(PasswordConfirmationDto request)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await profileService.DeleteAccountAsync(userId, request);

        return result.IsSuccess ? NoContent() : Problem(result.Error);
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
