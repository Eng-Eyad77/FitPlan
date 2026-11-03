
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.WorkoutSessions;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.WorkoutSessions;

// "آخر مرة": for each exercise, the sets the user did in the latest COMPLETED session that had it,
// plus the sets of the one before (the overload rules need two workouts to spot a slump).
public record ExerciseHistory(LastPerformanceDto Last, SessionSetResponseDto[]? PreviousSets);

public static class LastPerformanceQuery
{
    public static async Task<Dictionary<string, ExerciseHistory>> GetAsync(
        FitPlanDbContext context,
        Guid userId,
        IReadOnlyCollection<string> exerciseIds)
    {
        if (exerciseIds.Count == 0)
        {
            return [];
        }

        // 1. for each exercise, the ids of its two latest completed session exercises
        var latest = await context.SessionExercises
            .Where(se => exerciseIds.Contains(se.ExerciseId)
                && se.WorkoutSession.UserId == userId
                && se.WorkoutSession.CompletedAt != null)
            .GroupBy(se => se.ExerciseId)
            .Select(group => group
                .OrderByDescending(se => se.WorkoutSession.CompletedAt)
                .Select(se => se.Id)
                .Take(2)
                .ToList())
            .ToListAsync();

        var ids = latest.SelectMany(pair => pair).ToList();

        // 2. load their sets
        var rows = await context.SessionExercises
            .AsNoTracking()
            .Where(se => ids.Contains(se.Id))
            .Select(se => new
            {
                se.ExerciseId,
                PerformedAt = se.WorkoutSession.CompletedAt!.Value,
                Sets = se.Sets
                    .OrderBy(s => s.SetNumber)
                    .Select(s => new SessionSetResponseDto
                    {
                        Id = s.Id,
                        SetNumber = s.SetNumber,
                        Reps = s.Reps,
                        WeightKg = s.WeightKg
                    })
                    .ToArray()
            })
            .ToListAsync();

        return rows
            .GroupBy(row => row.ExerciseId)
            .ToDictionary(
                group => group.Key,
                group =>
                {
                    var ordered = group.OrderByDescending(row => row.PerformedAt).ToList();
                    return new ExerciseHistory(
                        new LastPerformanceDto { PerformedAt = ordered[0].PerformedAt, Sets = ordered[0].Sets },
                        ordered.ElementAtOrDefault(1)?.Sets);
                });
    }
}
