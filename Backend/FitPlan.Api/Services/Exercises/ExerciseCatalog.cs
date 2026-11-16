using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Exercises;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.Exercises;

// All exercises, kept in memory. Browsing the library is open without signing in, and every
// request used to wake the free database and spend its monthly allowance. The list only changes
// when exercises are imported, so it is read once and then refreshed after RefreshAfter.
public sealed class ExerciseCatalog(
    IServiceScopeFactory scopeFactory,
    TimeProvider time,
    ILogger<ExerciseCatalog> logger)
{
    public static readonly TimeSpan RefreshAfter = TimeSpan.FromHours(24);

    private readonly SemaphoreSlim _loading = new(1, 1);
    private Snapshot? _snapshot;

    public sealed record Snapshot(
        IReadOnlyList<ExerciseDto> All,
        IReadOnlyDictionary<string, ExerciseDto> ById,
        DateTimeOffset LoadedAt);

    public async Task<Snapshot> GetAsync(CancellationToken cancellationToken = default)
    {
        var current = _snapshot;
        if (current is not null && !IsStale(current))
        {
            return current;
        }

        // one database read at a time, even when many requests arrive together
        await _loading.WaitAsync(cancellationToken);
        try
        {
            current = _snapshot;
            if (current is not null && !IsStale(current))
            {
                return current;
            }

            try
            {
                _snapshot = await LoadAsync(cancellationToken);
                return _snapshot;
            }
            catch (Exception exception) when (current is not null)
            {
                // a stale list is better than an error; try again on a later request
                logger.LogWarning(exception, "Refreshing the exercise list failed, serving the list from {LoadedAt}", current.LoadedAt);
                return current;
            }
        }
        finally
        {
            _loading.Release();
        }
    }

    private bool IsStale(Snapshot snapshot) => time.GetUtcNow() - snapshot.LoadedAt >= RefreshAfter;

    private async Task<Snapshot> LoadAsync(CancellationToken cancellationToken)
    {
        await using var scope = scopeFactory.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<FitPlanDbContext>();

        var all = await context.Exercises
            .AsNoTracking()
            .OrderBy(e => e.Id)
            .Select(e => new ExerciseDto
            {
                Id = e.Id,
                Name = e.Name,
                BodyPart = e.BodyPart,
                GifUrl = e.GifUrl,
                Instructions = e.Instructions
            })
            .ToListAsync(cancellationToken);

        logger.LogInformation("Loaded {Count} exercises into memory", all.Count);

        // SQL Server compares ids without case, so the lookup does too
        var byId = all.ToDictionary(e => e.Id, StringComparer.OrdinalIgnoreCase);
        return new Snapshot(all, byId, time.GetUtcNow());
    }
}
