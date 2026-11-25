using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.Extensions;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Admin;
using FitPlan.Api.Services.Exercises;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Controllers;

// Phase 12C: fix exercise text in both languages, hide and show exercises, and check their GIF links.
// Reads the database directly (only the admin uses it); every change refreshes the library's cached list.
[Route("api/admin/exercises")]
[Authorize(Policy = AuthenticationExtensions.AdminPolicy)]
public class AdminExercisesController(
    FitPlanDbContext context,
    ExerciseCatalog catalog,
    IHttpClientFactory httpClients,
    TimeProvider time) : ApiControllerBase
{
    public const string GifCheckClient = "gif-check";

    private static readonly GifStatus[] Broken = [GifStatus.Missing, GifStatus.NotAGif];

    // filter: all, no-demo (the link is broken), not-checked or hidden. search: part of the name in
    // either language, or the id.
    [HttpGet]
    public async Task<IActionResult> List(string? search, string filter = "all", int page = 1, int pageSize = 25)
    {
        page = Math.Max(page, 1);
        pageSize = Math.Clamp(pageSize, 1, 100);

        var exercises = context.Exercises.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var text = search.Trim();
            exercises = exercises.Where(e => e.Name.Contains(text) || e.Id == text ||
                context.ExerciseTranslations.Any(t => t.ExerciseId == e.Id && t.Name.Contains(text)));
        }

        var counts = new AdminExerciseCountsDto(
            await exercises.CountAsync(),
            await exercises.CountAsync(e => e.GifStatus != null && Broken.Contains(e.GifStatus.Value)),
            await exercises.CountAsync(e => e.GifStatus == null),
            await exercises.CountAsync(e => e.Hidden));

        exercises = filter switch
        {
            "no-demo" => exercises.Where(e => e.GifStatus != null && Broken.Contains(e.GifStatus.Value)),
            "not-checked" => exercises.Where(e => e.GifStatus == null),
            "hidden" => exercises.Where(e => e.Hidden),
            _ => exercises
        };

        var total = await exercises.CountAsync();
        var items = await exercises
            .OrderBy(e => e.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(e => new AdminExerciseRowDto(
                e.Id,
                e.Name,
                context.ExerciseTranslations.Where(t => t.ExerciseId == e.Id && t.Language == ContentLanguage.Arabic).Select(t => t.Name).FirstOrDefault(),
                e.BodyPart,
                e.Hidden,
                e.GifStatus))
            .ToArrayAsync();

        return Ok(new AdminExerciseListDto(items, page, (total + pageSize - 1) / pageSize, total, counts));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Get(string id)
    {
        var exercise = await context.Exercises.AsNoTracking().FirstOrDefaultAsync(e => e.Id == id);
        if (exercise is null)
        {
            return Problem(Errors.ExerciseNotFound);
        }

        var arabic = await context.ExerciseTranslations.AsNoTracking()
            .FirstOrDefaultAsync(t => t.ExerciseId == id && t.Language == ContentLanguage.Arabic);
        var plans = await context.WorkoutPlanExercises.Where(p => p.ExerciseId == id).Select(p => p.WorkoutPlanId).Distinct().CountAsync();
        var workouts = await context.SessionExercises.Where(s => s.ExerciseId == id).Select(s => s.WorkoutSessionId).Distinct().CountAsync();

        return Ok(new AdminExerciseDetailDto(exercise.Id, exercise.BodyPart, exercise.GifUrl, exercise.GifStatus, exercise.GifCheckedAt,
            exercise.Hidden, exercise.Name, exercise.Instructions, arabic?.Name, arabic?.Instructions, plans, workouts));
    }

    // Saves the English and Arabic text together. The Arabic counts as reviewed: a person wrote it.
    [HttpPut("{id}/text")]
    public async Task<IActionResult> SaveText(string id, AdminExerciseTextDto request)
    {
        var english = Clean(request.EnglishInstructions);
        var arabicSteps = Clean(request.ArabicInstructions);
        if (english.Count == 0 || arabicSteps.Count == 0)
        {
            return Problem(Errors.ExerciseTextIncomplete);
        }

        var exercise = await context.Exercises.FirstOrDefaultAsync(e => e.Id == id);
        if (exercise is null)
        {
            return Problem(Errors.ExerciseNotFound);
        }

        exercise.Name = request.EnglishName.Trim();
        exercise.Instructions = english;

        var arabic = await context.ExerciseTranslations.FirstOrDefaultAsync(t => t.ExerciseId == id && t.Language == ContentLanguage.Arabic);
        if (arabic is null)
        {
            context.ExerciseTranslations.Add(new ExerciseTranslation
            {
                ExerciseId = id,
                Language = ContentLanguage.Arabic,
                Name = request.ArabicName.Trim(),
                Instructions = arabicSteps,
                Reviewed = true
            });
        }
        else
        {
            arabic.Name = request.ArabicName.Trim();
            arabic.Instructions = arabicSteps;
            arabic.Reviewed = true;
        }

        return await SaveAsync("Edited exercise text", $"{exercise.Id} {exercise.Name}");
    }

    [HttpPost("{id}/hide")]
    public Task<IActionResult> Hide(string id) => SetHiddenAsync(id, true);

    [HttpPost("{id}/show")]
    public Task<IActionResult> Show(string id) => SetHiddenAsync(id, false);

    // One exercise's link, checked now.
    [HttpPost("{id}/check-gif")]
    public async Task<IActionResult> CheckGif(string id, CancellationToken cancellationToken)
    {
        var exercise = await context.Exercises.FirstOrDefaultAsync(e => e.Id == id, cancellationToken);
        if (exercise is null)
        {
            return Problem(Errors.ExerciseNotFound);
        }

        (exercise.GifStatus, _) = await GifLink.CheckAsync(httpClients.CreateClient(GifCheckClient), exercise.GifUrl, cancellationToken, attempts: 2);
        exercise.GifCheckedAt = time.GetUtcNow().UtcDateTime;
        await context.SaveChangesAsync(cancellationToken);

        return Ok(new { exercise.GifStatus, exercise.GifCheckedAt });
    }

    // Checks the links of one batch, in id order. The admin calls it again with NextOffset until it
    // reaches Total, so no request runs long and nothing runs in the background. Run it when you
    // choose, not on a timer, so it doesn't spend the free plan's CPU.
    [HttpPost("check-gifs")]
    public async Task<IActionResult> CheckGifs(AdminGifCheckRequestDto request, CancellationToken cancellationToken)
    {
        var total = await context.Exercises.CountAsync(cancellationToken);
        var batch = await context.Exercises
            .OrderBy(e => e.Id)
            .Skip(request.Offset)
            .Take(request.Count)
            .ToListAsync(cancellationToken);

        var client = httpClients.CreateClient(GifCheckClient);
        var now = time.GetUtcNow().UtcDateTime;
        var results = new GifStatus[batch.Count];
        await Parallel.ForAsync(0, batch.Count, new ParallelOptions { MaxDegreeOfParallelism = 4, CancellationToken = cancellationToken },
            async (i, token) => (results[i], _) = await GifLink.CheckAsync(client, batch[i].GifUrl, token, attempts: 2));

        for (var i = 0; i < batch.Count; i++)
        {
            batch[i].GifStatus = results[i];
            batch[i].GifCheckedAt = now;
        }

        if (request.Offset == 0)
        {
            await AddAuditAsync("Started GIF link check", null);
        }

        await context.SaveChangesAsync(cancellationToken);

        return Ok(new AdminGifCheckResultDto(
            batch.Count,
            request.Offset + batch.Count,
            total,
            results.Count(r => Broken.Contains(r)),
            results.Count(r => r == GifStatus.Unreachable)));
    }

    private async Task<IActionResult> SetHiddenAsync(string id, bool hidden)
    {
        var exercise = await context.Exercises.FirstOrDefaultAsync(e => e.Id == id);
        if (exercise is null)
        {
            return Problem(Errors.ExerciseNotFound);
        }

        exercise.Hidden = hidden;
        return await SaveAsync(hidden ? "Hid exercise" : "Showed exercise", $"{exercise.Id} {exercise.Name}");
    }

    private async Task<IActionResult> SaveAsync(string action, string target)
    {
        await AddAuditAsync(action, target);
        await context.SaveChangesAsync();
        await catalog.InvalidateAsync();
        return NoContent();
    }

    private async Task AddAuditAsync(string action, string? target)
    {
        TryGetUserId(out var adminId);
        var admin = await context.Users.AsNoTracking().FirstAsync(u => u.Id == adminId);
        AdminAudit.Add(context, admin, action, target, time.GetUtcNow().UtcDateTime);
    }

    // trims each step and drops empty ones
    private static List<string> Clean(List<string> steps) =>
        [.. steps.Select(s => s.Trim()).Where(s => s.Length > 0)];
}
