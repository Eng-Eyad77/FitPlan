using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Profile;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Auth;
using FitPlan.Api.Services.BodyWeight;
using FitPlan.Api.Services.Pictures;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;


namespace FitPlan.Api.Services.Profile;

public class ProfileService(
    FitPlanDbContext context,
    ProfilePictureStorage pictures,
    TimeProvider time,
    IBodyWeightService bodyWeightService) : IProfileService
{
    private const long MaxFileSize = 5 * 1024 * 1024; // 5 MB in bytes


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


    public async Task<Result<ProfileDto>> UpdateWeeklyGoalAsync(Guid userId, UpdateWeeklyGoalDto request)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
        {
            return Result<ProfileDto>.Failure(Errors.UserNotFound);
        }

        if (request.WeeklyGoal != user.WeeklyGoal)
        {
            user.WeeklyGoal = request.WeeklyGoal;
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

        // F-20: the bytes decide, not the file name or the declared type
        byte[] bytes;
        await using (var stream = file.OpenReadStream())
        using (var buffer = new MemoryStream())
        {
            await stream.CopyToAsync(buffer);
            bytes = buffer.ToArray();
        }

        if (ProfilePictureStorage.DetectImage(bytes) is not { } image)
        {
            return Result<ProfileDto>.Failure(Errors.InvalidFile);
        }

        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
        {
            return Result<ProfileDto>.Failure(Errors.UserNotFound);
        }

        var oldPictureUrl = user.ProfilePictureUrl;

        user.ProfilePictureUrl = await pictures.SaveAsync(bytes, image.Extension);
        user.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync();

        pictures.Delete(oldPictureUrl);

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

        pictures.Delete(pictureWantToDelete);

        return Result<ProfileDto>.Success(await ToProfileDtoAsync(user));
    }


    public async Task<Result<(string Path, string ContentType)>> GetProfilePictureAsync(Guid userId)
    {
        var pictureUrl = await context.Users
            .Where(u => u.Id == userId)
            .Select(u => u.ProfilePictureUrl)
            .FirstOrDefaultAsync();

        return pictures.Find(pictureUrl) is { } file
            ? Result<(string, string)>.Success(file)
            : Result<(string, string)>.Failure(Errors.PictureNotFound);
    }


    // A new recovery code replaces the old one, which stops working.
    public async Task<Result<RecoveryCodeDto>> CreateRecoveryCodeAsync(Guid userId, PasswordConfirmationDto request)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
        {
            return Result<RecoveryCodeDto>.Failure(Errors.UserNotFound);
        }

        if (!PasswordMatches(user, request.Password))
        {
            return Result<RecoveryCodeDto>.Failure(Errors.WrongPassword);
        }

        var code = RecoveryCodes.Generate();
        RecoveryCodes.Assign(user, code, time.GetUtcNow().UtcDateTime);
        await context.SaveChangesAsync();

        return Result<RecoveryCodeDto>.Success(new RecoveryCodeDto(code));
    }


    // F-02: removes the user and everything they own: plans, workouts with their exercises, sets and
    // cardio, weights, logins and the picture. Workouts don't cascade from the user, so they go first,
    // in the same transaction.
    public async Task<Result<bool>> DeleteAccountAsync(Guid userId, PasswordConfirmationDto request)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
        {
            return Result<bool>.Failure(Errors.UserNotFound);
        }

        if (!PasswordMatches(user, request.Password))
        {
            return Result<bool>.Failure(Errors.WrongPassword);
        }

        var pictureUrl = user.ProfilePictureUrl;

        // the retry strategy needs the whole transaction inside it, so a retry repeats all of it
        await context.Database.CreateExecutionStrategy().ExecuteAsync(async () =>
        {
            await using var transaction = await context.Database.BeginTransactionAsync();
            await context.WorkoutSessions.Where(s => s.UserId == userId).ExecuteDeleteAsync();
            await context.Users.Where(u => u.Id == userId).ExecuteDeleteAsync();
            await transaction.CommitAsync();
        });

        pictures.Delete(pictureUrl);

        return Result<bool>.Success(true);
    }


    private static bool PasswordMatches(User user, string password) =>
        new PasswordHasher<User>().VerifyHashedPassword(user, user.PasswordHash, password) != PasswordVerificationResult.Failed;

    private async Task<ProfileDto> ToProfileDtoAsync(User user) => new()
    {
        Id = user.Id,
        Username = user.Username,
        Bio = user.Bio,
        ProfilePictureUrl = user.ProfilePictureUrl,
        CurrentWeightKg = await bodyWeightService.GetCurrentWeightAsync(user.Id),
        WeeklyGoal = user.WeeklyGoal,
        HasRecoveryCode = user.RecoveryCodeHash is not null,
        CreatedAt = user.CreatedAt,
        UpdatedAt = user.UpdatedAt
    };
}
