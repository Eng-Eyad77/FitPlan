using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.Extensions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace FitPlan.Api.Controllers;

// Phase 12E: the admin's first screen. The figures are counted on demand and kept for 10 minutes, so
// opening the page again doesn't keep the free database awake; refresh=true counts again.
[Route("api/admin/overview")]
[Authorize(Policy = AuthenticationExtensions.AdminPolicy)]
public class AdminOverviewController(FitPlanDbContext context, IMemoryCache cache, TimeProvider time) : ApiControllerBase
{
    public static readonly TimeSpan KeptFor = TimeSpan.FromMinutes(10);

    // Resend's free plan
    public const int EmailsPerDayLimit = 100;

    private const string CacheKey = "admin-overview";

    [HttpGet]
    public async Task<IActionResult> Get(bool refresh = false)
    {
        if (refresh || !cache.TryGetValue(CacheKey, out AdminOverviewDto? overview))
        {
            overview = await CountAsync();
            cache.Set(CacheKey, overview, KeptFor);
        }

        return Ok(overview);
    }

    private async Task<AdminOverviewDto> CountAsync()
    {
        var now = time.GetUtcNow().UtcDateTime;
        var today = now.Date;
        var weekAgo = today.AddDays(-6);
        var twoWeeksAgo = today.AddDays(-13);
        var monthStart = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var signUpsFrom = today.AddDays(-55);

        var workouts = context.WorkoutSessions.Where(s => s.CompletedAt != null);
        var workoutDays = await workouts
            .Where(s => s.StartedAt >= twoWeeksAgo)
            .GroupBy(s => s.StartedAt.Date)
            .Select(g => new { Day = g.Key, Count = g.Count() })
            .ToDictionaryAsync(g => g.Day, g => g.Count);
        var perDay = Enumerable.Range(0, 14).Select(i => workoutDays.GetValueOrDefault(twoWeeksAgo.AddDays(i))).ToArray();

        var volume = await context.SessionSets
            .Where(s => s.WeightKg != null && s.SessionExercise.WorkoutSession.CompletedAt != null
                && s.SessionExercise.WorkoutSession.StartedAt >= twoWeeksAgo)
            .GroupBy(s => s.SessionExercise.WorkoutSession.StartedAt >= weekAgo)
            .Select(g => new { Recent = g.Key, Kg = g.Sum(s => s.Reps * s.WeightKg!.Value) })
            .ToDictionaryAsync(g => g.Recent, g => g.Kg);

        var signUpDates = await context.Users.Where(u => u.CreatedAt >= signUpsFrom).Select(u => u.CreatedAt).ToListAsync();
        var perWeek = Enumerable.Range(0, 8)
            .Select(i => signUpDates.Count(d => d >= signUpsFrom.AddDays(7 * i) && d < signUpsFrom.AddDays(7 * (i + 1))))
            .ToArray();

        var cardio = await context.CardioEntries
            .Where(c => c.RecordedAt >= monthStart)
            .GroupBy(c => c.Machine)
            .Select(g => new { Machine = g.Key, Count = g.Count() })
            .OrderByDescending(g => g.Count)
            .ToListAsync();

        var topExercises = await context.SessionExercises
            .Where(e => e.WorkoutSession.CompletedAt != null && e.WorkoutSession.StartedAt >= monthStart)
            .GroupBy(e => e.Exercise.Name)
            .Select(g => new { Name = g.Key, Workouts = g.Select(e => e.WorkoutSessionId).Distinct().Count() })
            .OrderByDescending(e => e.Workouts)
            .ThenBy(e => e.Name)
            .Take(5)
            .Select(e => new AdminExerciseUseDto(e.Name, e.Workouts))
            .ToListAsync();

        return new AdminOverviewDto(
            now,
            await context.Users.CountAsync(),
            await context.Users.CountAsync(u => u.CreatedAt >= weekAgo),
            await context.WorkoutSessions.Where(s => s.StartedAt >= weekAgo).Select(s => s.UserId).Distinct().CountAsync(),
            perDay[7..].Sum(),
            perDay[..7].Sum(),
            volume.GetValueOrDefault(true),
            volume.GetValueOrDefault(false),
            cardio.Sum(c => c.Count),
            cardio.FirstOrDefault()?.Machine.ToString(),
            await context.ProblemReports.CountAsync(r => r.CreatedAt >= weekAgo),
            await context.Exercises.CountAsync(e => e.GifStatus != null && AdminExercisesController.Broken.Contains(e.GifStatus.Value)),
            await context.EmailCodes.CountAsync(c => c.CreatedAt >= today),
            EmailsPerDayLimit,
            perDay,
            perWeek,
            topExercises);
    }
}
