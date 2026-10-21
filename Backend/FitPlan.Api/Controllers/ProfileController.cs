using System.Security.Claims;
using FitPlan.Api.DTOs.Profile;
using FitPlan.Api.Services.Profile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;



namespace FitPlan.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/profile")]
public class ProfileController(IProfileService profileService) : ControllerBase
{

    [HttpGet("me")]

    public async Task<IActionResult> GetUserProfile()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;


        if (!Guid.TryParse(userId, out var result))
        {   
            return Unauthorized();
        }

          var userProfile = await profileService.GetUserProfileAsync(result);
          
            if (userProfile is null)
            {
                return NotFound();
            }

            return Ok(userProfile);


    }




    [HttpPut("me")]
    public async Task<IActionResult> UpdateProfile(UpdateBioRequestDto updateProfileRequest)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;


        if (!Guid.TryParse(userId, out var result))
        {
            return Unauthorized();
        }



         var updatedUserProfile = await profileService.UpdateBioAsync(result, updateProfileRequest );
            if (updatedUserProfile is null)
            {
                return NotFound();
            }

              return Ok(updatedUserProfile);
        
    }


    [HttpPost("me/picture")]
    public async Task<IActionResult> uploadProfilePicture(IFormFile file)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (!Guid.TryParse(userId, out var result))
        {
            return Unauthorized();
        }

        var userUploadedPicture = await profileService.UploadProfilePictureAsync(result,file);

        if(!userUploadedPicture.Succeeded)
        {
            return userUploadedPicture.ErrorCode switch 
            {
                "InvalidFile"   => BadRequest("The uploaded file is invalid or corrupted."),
                "FileTooLarge"  => StatusCode(413, "The file size exceeds the allowed limit."),
                "UserNotFound"  => NotFound("The specified user could not be found."),
                              _ => StatusCode(500, "An unexpected internal server error occurred.")
            };
        }

        return Ok(userUploadedPicture.Data);

    }



    [HttpDelete("me/picture")]
    public async Task<IActionResult> DeleteProfilePicture()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;


         if (!Guid.TryParse(userId, out var result))
        {
            return Unauthorized();
        }

        var deleteResult = await profileService.DeleteProfilePictureAsync(result);


        if(!deleteResult.Succeeded)
        {
            return deleteResult.ErrorCode switch
            {
                "UserNotFound" => NotFound(),
                _ => StatusCode(500)
            };
        }


        return Ok(deleteResult.Data);

    }


}
