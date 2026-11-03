
using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.Profile;

namespace FitPlan.Api.Services.Profile;

public interface IProfileService
{
    Task<Result<ProfileDto>> GetUserProfileAsync(Guid userId);

    Task<Result<ProfileDto>> UpdateBioAsync(Guid userId, UpdateBioRequestDto request);

    Task<Result<ProfileDto>> UpdateWeeklyGoalAsync(Guid userId, UpdateWeeklyGoalDto request);

    Task<Result<ProfileDto>> UploadProfilePictureAsync(Guid userId, IFormFile file);

    Task<Result<ProfileDto>> DeleteProfilePictureAsync(Guid userId);
}
