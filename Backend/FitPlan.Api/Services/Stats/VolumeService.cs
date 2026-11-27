using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Stats;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.Stats;

// The lifetime-volume milestones (Phase 10). The app owns the names and pictures,
// so they can be translated; the server only knows the keys and the weights.
public static class VolumeMilestones
{
    public static readonly (string Key, decimal ThresholdKg)[] All =
    [
        ("grand-piano", 500m),
        ("small-car", 1_000m),
        ("elephant", 6_000m),
        ("city-bus", 12_000m),
        ("loaded-truck", 40_000m),
        ("blue-whale", 150_000m),
        // the London Eye and the Eiffel Tower were dropped on 2026-11-25: years out of reach
        ("jumbo-jet", 450_000m)
    ];
}

public interface IVolumeService
{
    Task<VolumeStatsDto> GetAsync(Guid userId);

    // Saves the milestones the user's history has passed and returns the keys crossed by
    // [completedSessionId], the workout just finished. Milestones crossed by older workouts
    // (history from before this feature) are saved quietly, with the date they were crossed.
    Task<string[]> SyncAsync(Guid userId, Guid? completedSessionId = null);
}

public class VolumeService(FitPlanDbContext context) : IVolumeService
{
    public async Task<VolumeStatsDto> GetAsync(Guid userId)
    {
        await SyncAsync(userId);

        var total = await context.SessionSets
            .Where(s => s.SessionExercise.WorkoutSession.UserId == userId
                && s.SessionExercise.WorkoutSession.CompletedAt != null)
            .SumAsync(s => s.Reps * (s.WeightKg ?? 0));

        var reached = await context.VolumeMilestones
            .AsNoTracking()
            .Where(m => m.UserId == userId)
            .ToDictionaryAsync(m => m.Key, m => m.ReachedAt);

        return new VolumeStatsDto
        {
            TotalVolumeKg = total,
            Milestones = VolumeMilestones.All
                .Select(m => new VolumeMilestoneDto
                {
                    Key = m.Key,
                    ThresholdKg = m.ThresholdKg,
                    ReachedAt = reached.TryGetValue(m.Key, out var at) ? at : null
                })
                .ToArray()
        };
    }

    public async Task<string[]> SyncAsync(Guid userId, Guid? completedSessionId = null)
    {
        var saved = await context.VolumeMilestones
            .Where(m => m.UserId == userId)
            .Select(m => m.Key)
            .ToListAsync();

        var missing = VolumeMilestones.All.Where(m => !saved.Contains(m.Key)).ToList();
        if (missing.Count == 0)
        {
            return [];
        }

        // every finished workout with its volume, in the order they were finished
        var sessions = await context.WorkoutSessions
            .AsNoTracking()
            .Where(s => s.UserId == userId && s.CompletedAt != null)
            .OrderBy(s => s.CompletedAt)
            .ThenBy(s => s.Id)
            .Select(s => new
            {
                s.Id,
                CompletedAt = s.CompletedAt!.Value,
                VolumeKg = s.Exercises.SelectMany(e => e.Sets).Sum(set => set.Reps * (set.WeightKg ?? 0))
            })
            .ToListAsync();

        var crossed = new List<string>();
        var running = 0m;

        foreach (var session in sessions)
        {
            running += session.VolumeKg;

            foreach (var milestone in missing.Where(m => m.ThresholdKg <= running).ToList())
            {
                missing.Remove(milestone);
                context.VolumeMilestones.Add(new VolumeMilestone
                {
                    UserId = userId,
                    Key = milestone.Key,
                    ReachedAt = session.CompletedAt
                });

                if (session.Id == completedSessionId)
                {
                    crossed.Add(milestone.Key);
                }
            }
        }

        try
        {
            await context.SaveChangesAsync();
        }
        catch (DbUpdateException exception) when (exception.IsUniqueConstraintViolation())
        {
            // another request saved them at the same moment: they are there, and the
            // celebration belongs to that request
            context.ChangeTracker.Clear();
            return [];
        }

        return [.. crossed];
    }
}
