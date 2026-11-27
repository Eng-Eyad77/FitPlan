using System.Collections.Concurrent;
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
// Phase 11C: the translations are part of the same list, so a translated name costs no extra read.
public sealed class ExerciseCatalog(
    IServiceScopeFactory scopeFactory,
    TimeProvider time,
    ILogger<ExerciseCatalog> logger,
    IConfiguration configuration)
{
    public const string CacheFileSetting = "Exercises:CacheFile";
    public static readonly TimeSpan RefreshAfter = TimeSpan.FromHours(24);

    // a saved file with another version is from an older build, so the database is read instead
    private const int CacheVersion = 3;

    private readonly string? _cacheFile = configuration[CacheFileSetting] is { Length: > 0 } path ? path : null;
    private readonly SemaphoreSlim _loading = new(1, 1);
    private readonly ConcurrentDictionary<string, byte> _reportedMissing = new(StringComparer.OrdinalIgnoreCase);
    private Snapshot? _snapshot;
    private bool _fileChecked;

    public sealed record ExerciseText(string Name, List<string> Instructions);

    // One language's text. Terms are keyed "kind:term", for example "muscle:biceps".
    public sealed record LanguageContent(
        IReadOnlyDictionary<string, ExerciseText> Exercises,
        IReadOnlyDictionary<string, string> Terms)
    {
        // the translated names, ready for search
        public IReadOnlyDictionary<string, string> SearchNames { get; } = Exercises.ToDictionary(
            e => e.Key, e => ArabicText.Normalize(e.Value.Name), StringComparer.OrdinalIgnoreCase);
    }

    public sealed record Snapshot(
        IReadOnlyList<ExerciseDto> All,
        IReadOnlyDictionary<string, ExerciseDto> ById,
        DateTimeOffset LoadedAt,
        IReadOnlyDictionary<string, LanguageContent> Languages);

    // After an admin changes an exercise (12C): the next request reads the database again, not the saved
    // file. Waits for a load already running, so that load can't put the old list back afterwards.
    public async Task InvalidateAsync()
    {
        await _loading.WaitAsync();
        try
        {
            _fileChecked = true;
            _snapshot = null;
        }
        finally
        {
            _loading.Release();
        }
    }

    public static string TermKey(string kind, string term) => $"{kind}:{term}";

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

    // The exercise in the given language. English, or a language with no text at all, gives the
    // English row back; a missing translation is logged once per exercise, so gaps show in the logs.
    public ExerciseDto Localize(Snapshot snapshot, ExerciseDto exercise, string language)
    {
        if (!snapshot.Languages.TryGetValue(language, out var content))
        {
            return exercise;
        }

        var text = Text(content, exercise.Id, language);
        return exercise with
        {
            Name = text?.Name ?? exercise.Name,
            EnglishName = text is null ? null : exercise.Name,
            Instructions = text?.Instructions ?? exercise.Instructions,
            Equipments = Terms(content, "equipment", exercise.Equipments, language),
            TargetMuscles = Terms(content, "muscle", exercise.TargetMuscles, language),
            SecondaryMuscles = Terms(content, "muscle", exercise.SecondaryMuscles, language)
        };
    }

    // The same for a response that only shows the exercise's name (and maybe its steps).
    public void Localize(Snapshot snapshot, ILocalizedExercise item, string language)
    {
        if (!snapshot.Languages.TryGetValue(language, out var content) || item.EnglishName is not null)
        {
            return;
        }

        var text = Text(content, item.ExerciseId, language);
        if (text is null)
        {
            return;
        }

        item.EnglishName = item.Name;
        item.Name = text.Name;
        if (item is ILocalizedSteps steps)
        {
            steps.Instructions = text.Instructions;
        }
    }

    private ExerciseText? Text(LanguageContent content, string exerciseId, string language)
    {
        if (content.Exercises.TryGetValue(exerciseId, out var text))
        {
            return text;
        }

        if (_reportedMissing.TryAdd($"{language}:{exerciseId}", 0))
        {
            logger.LogWarning("Exercise {ExerciseId} has no {Language} text, showing English", exerciseId, language);
        }

        return null;
    }

    private List<string> Terms(LanguageContent content, string kind, List<string> terms, string language) =>
        terms.Select(term =>
        {
            if (content.Terms.TryGetValue(TermKey(kind, term), out var text))
            {
                return text;
            }

            if (_reportedMissing.TryAdd($"{language}:{kind}:{term}", 0))
            {
                logger.LogWarning("The {Kind} {Term} has no {Language} text, showing English", kind, term, language);
            }

            return term;
        }).ToList();

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
                Instructions = e.Instructions,
                Equipments = e.Equipments,
                TargetMuscles = e.TargetMuscles,
                SecondaryMuscles = e.SecondaryMuscles,
                Hidden = e.Hidden
            })
            .ToListAsync(cancellationToken);

        var translations = await context.ExerciseTranslations
            .AsNoTracking()
            .Select(t => new { t.Language, t.ExerciseId, t.Name, t.Instructions })
            .ToListAsync(cancellationToken);

        var terms = await context.TermTranslations
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        var languages = translations.Select(t => t.Language)
            .Concat(terms.Select(t => t.Language))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToDictionary(
                language => language,
                language => new CachedLanguage(
                    translations
                        .Where(t => t.Language.Equals(language, StringComparison.OrdinalIgnoreCase))
                        .ToDictionary(t => t.ExerciseId, t => new ExerciseText(t.Name, t.Instructions), StringComparer.OrdinalIgnoreCase),
                    terms
                        .Where(t => t.Language.Equals(language, StringComparison.OrdinalIgnoreCase))
                        .ToDictionary(t => TermKey(t.Kind, t.Term), t => t.Text, StringComparer.OrdinalIgnoreCase)),
                StringComparer.OrdinalIgnoreCase);

        logger.LogInformation("Loaded {Count} exercises into memory, with text in {Languages}", all.Count,
            languages.Count == 0 ? "English only" : string.Join(", ", languages.Select(l => $"{l.Key} ({l.Value.Exercises.Count})")));

        return ToSnapshot(all, languages, time.GetUtcNow());
    }

    // SQL Server compares ids without case, so the lookups do too
    private static Snapshot ToSnapshot(
        IReadOnlyList<ExerciseDto> all, IReadOnlyDictionary<string, CachedLanguage> languages, DateTimeOffset loadedAt) =>
        new(all,
            all.ToDictionary(e => e.Id, StringComparer.OrdinalIgnoreCase),
            loadedAt,
            languages.ToDictionary(
                l => l.Key,
                l => new LanguageContent(
                    new Dictionary<string, ExerciseText>(l.Value.Exercises, StringComparer.OrdinalIgnoreCase),
                    new Dictionary<string, string>(l.Value.Terms, StringComparer.OrdinalIgnoreCase)),
                StringComparer.OrdinalIgnoreCase));

    private sealed record CachedLanguage(Dictionary<string, ExerciseText> Exercises, Dictionary<string, string> Terms);

    private sealed record CacheFile(
        int Version, DateTimeOffset LoadedAt, List<ExerciseDto> Exercises, Dictionary<string, CachedLanguage>? Languages);

    // A missing, unreadable or older file only means the database is read instead.
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
            if (saved?.Exercises is null || saved.Version != CacheVersion)
            {
                return null;
            }

            logger.LogInformation("Loaded {Count} exercises from {File}, saved at {LoadedAt}", saved.Exercises.Count, _cacheFile, saved.LoadedAt);
            return ToSnapshot(saved.Exercises, saved.Languages ?? [], saved.LoadedAt);
        }
        catch (Exception exception) when (exception is IOException or JsonException or UnauthorizedAccessException or ArgumentException)
        {
            logger.LogWarning(exception, "Couldn't read the saved exercise list at {File}", _cacheFile);
            return null;
        }
    }

    private static CacheFile ToCacheFile(Snapshot snapshot) => new(
        CacheVersion,
        snapshot.LoadedAt,
        [.. snapshot.All],
        snapshot.Languages.ToDictionary(
            l => l.Key,
            l => new CachedLanguage(l.Value.Exercises.ToDictionary(), l.Value.Terms.ToDictionary())));

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
                await JsonSerializer.SerializeAsync(stream, ToCacheFile(snapshot), JsonSerializerOptions.Web, cancellationToken);
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
