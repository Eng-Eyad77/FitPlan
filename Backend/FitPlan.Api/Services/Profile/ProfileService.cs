using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Profile;
using FitPlan.Api.Models;
using FitPlan.Api.Services.BodyWeight;
using Microsoft.EntityFrameworkCore;


namespace FitPlan.Api.Services.Profile;

public class ProfileService(
    FitPlanDbContext context,
    IWebHostEnvironment webHost,
    IBodyWeightService bodyWeightService) : IProfileService
{
    private const long MaxFileSize = 5 * 1024 * 1024; // 5 MB in bytes

    private static readonly string[] AllowedExtensions = [".jpg", ".jpeg", ".png"];
    private static readonly string[] AllowedMimeTypes = ["image/jpeg", "image/png"];


    public async Task<Result<ProfileDto>> GetUserProfileAsync(Guid userId)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
        {
            return Result<ProfileDto>.Failure(Errors.UserNotFound);
        }

        return Result<ProfileDto>.Success(await ToProfileDtoAsync(user));
    }


    public async Task<Result<ProfileDto>> UpdateBioAsync(Guid userId, UpdateBioRequestDto request)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
        {
            return Result<ProfileDto>.Failure(Errors.UserNotFound);
        }

        if (request.Bio != user.Bio)
        {
            user.Bio = request.Bio;
            user.UpdatedAt = DateTime.UtcNow;
            await context.SaveChangesAsync();
        }

        return Result<ProfileDto>.Success(await ToProfileDtoAsync(user));
    }


    public async Task<Result<ProfileDto>> UploadProfilePictureAsync(Guid userId, IFormFile file)
    {
        if (file == null || file.Length <= 0)
        {
            return Result<ProfileDto>.Failure(Errors.InvalidFile);
        }

        if (file.Length > MaxFileSize)
        {
            return Result<ProfileDto>.Failure(Errors.FileTooLarge);
        }

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();

        if (!AllowedExtensions.Contains(extension) || !AllowedMimeTypes.Contains(file.ContentType))
        {
            return Result<ProfileDto>.Failure(Errors.InvalidFile);
        }

        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
        {
            return Result<ProfileDto>.Failure(Errors.UserNotFound);
        }

        var oldPictureUrl = user.ProfilePictureUrl;

        var uniqueFileName = $"{Guid.NewGuid()}{extension}";

        var targetFolder = GetProfilePicturesFolder();

        Directory.CreateDirectory(targetFolder);

        await using (var stream = new FileStream(Path.Combine(targetFolder, uniqueFileName), FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        user.ProfilePictureUrl = $"/uploads/profile-pictures/{uniqueFileName}";
        user.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync();

        DeletePictureFile(oldPictureUrl);

        return Result<ProfileDto>.Success(await ToProfileDtoAsync(user));
    }


    public async Task<Result<ProfileDto>> DeleteProfilePictureAsync(Guid userId)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
        {
            return Result<ProfileDto>.Failure(Errors.UserNotFound);
        }

        var pictureWantToDelete = user.ProfilePictureUrl;

        user.ProfilePictureUrl = null;
        user.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync();

        DeletePictureFile(pictureWantToDelete);

        return Result<ProfileDto>.Success(await ToProfileDtoAsync(user));
    }


    private string GetProfilePicturesFolder() =>
        Path.Combine(webHost.ContentRootPath, "wwwroot", "uploads", "profile-pictures");

    private void DeletePictureFile(string? pictureUrl)
    {
        if (string.IsNullOrWhiteSpace(pictureUrl))
        {
            return;
        }

        var filePath = Path.Combine(GetProfilePicturesFolder(), Path.GetFileName(pictureUrl));

        if (File.Exists(filePath))
        {
            File.Delete(filePath);
        }
    }

    private async Task<ProfileDto> ToProfileDtoAsync(User user) => new()
    {
        Id = user.Id,
        Username = user.Username,
        Bio = user.Bio,
        ProfilePictureUrl = user.ProfilePictureUrl,
        CurrentWeightKg = await bodyWeightService.GetCurrentWeightAsync(user.Id),
        CreatedAt = user.CreatedAt,
        UpdatedAt = user.UpdatedAt
    };
}
