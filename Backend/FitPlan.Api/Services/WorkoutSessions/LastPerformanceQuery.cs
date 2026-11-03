
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.WorkoutSessions;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.WorkoutSessions;

// "آخر مرة": for each exercise, the sets the user did in the latest COMPLETED session that had it.
public static class LastPerformanceQuery
{
    public static async Task<Dictionary<string, LastPerformanceDto>> GetAsync(
        FitPlanDbContext context,
        Guid userId,
        IReadOnlyCollection<string> exerciseIds)
    {
        if (exerciseIds.Count == 0)
        {
            return [];
        }

        // 1. for each exercise, the id of its latest completed session exercise
        var latestSessionExerciseIds = await context.SessionExercises
            .Where(se => exerciseIds.Contains(se.ExerciseId)
                && se.WorkoutSession.UserId == userId
                && se.WorkoutSession.CompletedAt != null)
            .GroupBy(se => se.ExerciseId)
            .Select(group => group
                .OrderByDescending(se => se.WorkoutSession.CompletedAt)
                .Select(se => se.Id)
                .First())
            .ToListAsync();

        // 2. load their sets
        var lastPerformances = await context.SessionExercises
            .AsNoTracking()
            .Where(se => latestSessionExerciseIds.Contains(se.Id))
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

        return lastPerformances.ToDictionary(
            item => item.ExerciseId,
            item => new LastPerformanceDto
            {
                PerformedAt = item.PerformedAt,
                Sets = item.Sets
            });
    }
}
