using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.BodyWeight;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.BodyWeight;

public class BodyWeightService(FitPlanDbContext context) : IBodyWeightService
{
    public async Task<Result<BodyWeightEntryResponseDto>> AddEntryAsync(Guid userId, AddBodyWeightDto dto)
    {
        var userExists = await context.Users.AnyAsync(u => u.Id == userId);

        if (!userExists)
        {
            return Result<BodyWeightEntryResponseDto>.Failure(Errors.UserNotFound);
        }

        var entry = new BodyWeightEntry
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            WeightKg = dto.WeightKg,
            RecordedAt = DateTime.UtcNow
        };

        context.BodyWeightEntries.Add(entry);
        await context.SaveChangesAsync();

        return Result<BodyWeightEntryResponseDto>.Success(new BodyWeightEntryResponseDto
        {
            Id = entry.Id,
            WeightKg = entry.WeightKg,
            RecordedAt = entry.RecordedAt
        });
    }


    // newest first
    public async Task<BodyWeightEntryResponseDto[]> GetHistoryAsync(Guid userId)
    {
        return await context.BodyWeightEntries
            .AsNoTracking()
            .Where(b => b.UserId == userId)
            .OrderByDescending(b => b.RecordedAt)
            .Select(b => new BodyWeightEntryResponseDto
            {
                Id = b.Id,
                WeightKg = b.WeightKg,
                RecordedAt = b.RecordedAt
            })
            .ToArrayAsync();
    }


    public async Task<Result<bool>> DeleteEntryAsync(Guid userId, Guid id)
    {
        var entry = await context.BodyWeightEntries
            .FirstOrDefaultAsync(b => b.Id == id && b.UserId == userId);

        if (entry is null)
        {
            return Result<bool>.Failure(Errors.BodyWeightEntryNotFound);
        }

        context.BodyWeightEntries.Remove(entry);
        await context.SaveChangesAsync();

        return Result<bool>.Success(true);
    }


    // the current weight is simply the latest entry (null if the user never recorded one)
    public async Task<decimal?> GetCurrentWeightAsync(Guid userId)
    {
        return await context.BodyWeightEntries
            .Where(b => b.UserId == userId)
            .OrderByDescending(b => b.RecordedAt)
            .Select(b => (decimal?)b.WeightKg)
            .FirstOrDefaultAsync();
    }
}
