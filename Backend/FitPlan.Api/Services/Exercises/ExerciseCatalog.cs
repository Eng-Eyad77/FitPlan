using System.Text.Json;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Exercises;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.Exercises;

// All exercises, kept in memory. Browsing the library is open without signing in, and every
// request used to wake the free database and spend its monthly allowance. The list only changes
// when exercises are imported, so it is read once and then refreshed after RefreshAfter.
// The free App Service plan unloads an idle app, which empties memory, so each list read from the
// database is also saved to Exercises:CacheFile (a folder that survives restarts) and read back
// from there on start. The database stays the source of truth, because plans point at its rows.
public sealed class ExerciseCatalog(
    IServiceScopeFactory scopeFactory,
    TimeProvider time,
    ILogger<ExerciseCatalog> logger,
    IConfiguration configuration)
{
    public const string CacheFileSetting = "Exercises:CacheFile";
    public static readonly TimeSpan RefreshAfter = TimeSpan.FromHours(24);

    private readonly string? _cacheFile = configuration[CacheFileSetting] is { Length: > 0 } path ? path : null;
    private readonly SemaphoreSlim _loading = new(1, 1);
    private Snapshot? _snapshot;
    private bool _fileChecked;

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
            if (_snapshot is null && !_fileChecked)
            {
                _fileChecked = true;
                _snapshot = await ReadFileAsync(cancellationToken);
            }

            current = _snapshot;
            if (current is not null && !IsStale(current))
            {
                return current;
            }

            try
            {
                _snapshot = await LoadAsync(cancellationToken);
                await WriteFileAsync(_snapshot, cancellationToken);
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

    // a time in the future can only come from a wrong clock, so it counts as stale too
    private bool IsStale(Snapshot snapshot)
    {
        var age = time.GetUtcNow() - snapshot.LoadedAt;
        return age >= RefreshAfter || age < TimeSpan.Zero;
    }

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

        return ToSnapshot(all, time.GetUtcNow());
    }

    // SQL Server compares ids without case, so the lookup does too
    private static Snapshot ToSnapshot(IReadOnlyList<ExerciseDto> all, DateTimeOffset loadedAt) =>
        new(all, all.ToDictionary(e => e.Id, StringComparer.OrdinalIgnoreCase), loadedAt);

    private sealed record CacheFile(DateTimeOffset LoadedAt, List<ExerciseDto> Exercises);

    // A missing or unreadable file only means the database is read instead.
    private async Task<Snapshot?> ReadFileAsync(CancellationToken cancellationToken)
    {
        if (_cacheFile is null || !File.Exists(_cacheFile))
        {
            return null;
        }

        try
        {
            await using var stream = File.OpenRead(_cacheFile);
            var saved = await JsonSerializer.DeserializeAsync<CacheFile>(stream, JsonSerializerOptions.Web, cancellationToken);
            if (saved?.Exercises is null)
            {
                return null;
            }

            logger.LogInformation("Loaded {Count} exercises from {File}, saved at {LoadedAt}", saved.Exercises.Count, _cacheFile, saved.LoadedAt);
            return ToSnapshot(saved.Exercises, saved.LoadedAt);
        }
        catch (Exception exception) when (exception is IOException or JsonException or UnauthorizedAccessException or ArgumentException)
        {
            logger.LogWarning(exception, "Couldn't read the saved exercise list at {File}", _cacheFile);
            return null;
        }
    }

    // Saving is best effort: the list in memory is served either way.
    private async Task WriteFileAsync(Snapshot snapshot, CancellationToken cancellationToken)
    {
        if (_cacheFile is null)
        {
            return;
        }

        var temporary = _cacheFile + ".tmp";
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(_cacheFile))!);
            await using (var stream = File.Create(temporary))
            {
                await JsonSerializer.SerializeAsync(stream, new CacheFile(snapshot.LoadedAt, [.. snapshot.All]), JsonSerializerOptions.Web, cancellationToken);
            }

            // replace in one step, so a reader never sees half a file
            File.Move(temporary, _cacheFile, overwrite: true);
        }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException)
        {
            logger.LogWarning(exception, "Couldn't save the exercise list to {File}", _cacheFile);
        }
    }
}
