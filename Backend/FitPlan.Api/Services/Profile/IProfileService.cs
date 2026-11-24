
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

    Task<Result<(string Path, string ContentType)>> GetProfilePictureAsync(Guid userId);

    Task<Result<bool>> SendEmailChangeCodeAsync(Guid userId, ChangeEmailRequestDto request, string language);

    Task<Result<ProfileDto>> ConfirmEmailChangeAsync(Guid userId, ConfirmEmailChangeDto request, string language);

    Task<Result<bool>> DeleteAccountAsync(Guid userId, PasswordConfirmationDto request);
}
