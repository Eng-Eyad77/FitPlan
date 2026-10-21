using System;
using System.Security.Claims;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Profile;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using FitPlan.Api.Services.Profile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;


namespace FitPlan.Api.Services.Profile;

public class ProfileService(FitPlanDbContext context, IWebHostEnvironment webHost) : IProfileService
{

    public async Task<ProfileDto?> GetUserProfileAsync(Guid userId)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
        {
            return null;
        }

        return new ProfileDto
        {
            Id = user.Id,
            Username = user.Username,
            Bio = user.Bio,
            ProfilePictureUrl = user.ProfilePictureUrl,
            CreatedAt = user.CreatedAt,
            UpdatedAt = user.UpdatedAt
        };



    }






    public async Task<ProfileDto?> UpdateBioAsync(Guid userId, UpdateBioRequestDto request)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);


        if (user is null)
        {
            return null;
        }

        if (request.Bio != user.Bio)
        {

            user.Bio = request.Bio;
            user.UpdatedAt = DateTime.UtcNow;
            await context.SaveChangesAsync();

        }



        return new ProfileDto
        {
            Id = user.Id,
            Username = user.Username,
            Bio = user.Bio,
            ProfilePictureUrl = user.ProfilePictureUrl,
            CreatedAt = user.CreatedAt,
            UpdatedAt = user.UpdatedAt
        };

    }






    public async Task<ProfileOperationResult<ProfileDto>> UploadProfilePictureAsync(Guid userId, IFormFile file)
    {
        if (file == null || file.Length <= 0)
        {
            return new ProfileOperationResult<ProfileDto>
            (
                false,
                null,
                "InvalidFile"
            );
        }

        const long maxFileSize = 5 * 1024 * 1024; // 5 MB in bytes

        if (file.Length > maxFileSize)
        {
            return new ProfileOperationResult<ProfileDto>
            (
                false,
                null,
                "FileTooLarge"
            );
        }

        // 1. Get the file extension
        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();

        // 2. Define allowed extensions 
        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };
        var allowedMimeTypes = new[] { "image/jpeg", "image/png" };

        // 3. Perform the validation
        if (!allowedExtensions.Contains(extension) || !allowedMimeTypes.Contains(file.ContentType))
        {
            return new ProfileOperationResult<ProfileDto>
            (
                false,
                null,
                "InvalidFile"
            );
        }


        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (user is null)
        {
            return new ProfileOperationResult<ProfileDto>
            (
                false,
                null,
                "UserNotFound"
            );

        }

        var oldPictureUrl = user.ProfilePictureUrl;

        var uniqueFileName = $"{Guid.NewGuid()}{extension}";

        var targetFolder = Path.Combine
        (
            webHost.ContentRootPath,
            "wwwroot",
            "uploads",
            "profile-pictures"
        );

        var filePath = Path.Combine(targetFolder, uniqueFileName);

        Directory.CreateDirectory(targetFolder);

        await using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }



        user.ProfilePictureUrl = $"/uploads/profile-pictures/{uniqueFileName}";
        user.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync();


        if (!string.IsNullOrWhiteSpace(oldPictureUrl))
        {
            var oldFileName = Path.GetFileName(oldPictureUrl);

            var oldFilePath = Path.Combine(
                webHost.ContentRootPath,
                "wwwroot",
                "uploads",
                "profile-pictures",
                oldFileName
            );

            if (System.IO.File.Exists(oldFilePath))
            {
                System.IO.File.Delete(oldFilePath);
            }
        }

        var updatedProfile = new ProfileDto
        {
            Id = user.Id,
            Username = user.Username,
            Bio = user.Bio,
            ProfilePictureUrl = user.ProfilePictureUrl,
            CreatedAt = user.CreatedAt,
            UpdatedAt = user.UpdatedAt
        };

        return new ProfileOperationResult<ProfileDto>
        (
            true,
            updatedProfile,
            null
        );




    }





    public async Task<ProfileOperationResult<ProfileDto>> DeleteProfilePictureAsync(Guid userId)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (user is null)
        {
            return new ProfileOperationResult<ProfileDto>
            (
                false,
                null,
                "UserNotFound"
            );

        }

        var pictureWantToDelete = user.ProfilePictureUrl;


        user.ProfilePictureUrl = null;
        user.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync();

        if (!string.IsNullOrWhiteSpace(pictureWantToDelete))
        {
            var oldFileName = Path.GetFileName(pictureWantToDelete);

            var oldFilePath = Path.Combine(
                webHost.ContentRootPath,
                "wwwroot",
                "uploads",
                "profile-pictures",
                oldFileName
            );

            if (System.IO.File.Exists(oldFilePath))
            {
                System.IO.File.Delete(oldFilePath);
            }
        }

        var profileDto = new ProfileDto
        {
            Id = user.Id,
            Username = user.Username,
            Bio = user.Bio,
            ProfilePictureUrl = user.ProfilePictureUrl,
            CreatedAt = user.CreatedAt,
            UpdatedAt = user.UpdatedAt
        };

        return new ProfileOperationResult<ProfileDto>(true,profileDto,null); 


    }
}
