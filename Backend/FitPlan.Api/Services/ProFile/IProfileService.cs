
using FitPlan.Api.DTOs.Profile;
using Microsoft.AspNetCore.Http;

namespace FitPlan.Api.Services.Profile;

public interface IProfileService
{
    Task<ProfileDto?> GetUserProfileAsync(Guid userId);

    Task<ProfileDto?> UpdateBioAsync(
        Guid userId,
        UpdateBioRequestDto request);

    Task<ProfileOperationResult<ProfileDto>> UploadProfilePictureAsync(Guid userId, IFormFile file);

    Task<ProfileOperationResult<ProfileDto>> DeleteProfilePictureAsync(Guid userId);
}
