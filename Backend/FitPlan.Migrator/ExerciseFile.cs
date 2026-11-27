using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text.Encodings.Web;
using System.Text.Json;
using FitPlan.Api.DTOs.Exercises.External;

namespace FitPlan.Migrator;

// The detail lists came in Phase 11C: a file fetched before then has none, and imports without them.
public sealed record ExerciseRow(
    string Id,
    string Name,
    string GifUrl,
    string BodyPart,
    List<string> Instructions,
    List<string>? Equipments = null,
    List<string>? TargetMuscles = null,
    List<string>? SecondaryMuscles = null);

public sealed record ValidatedExercises(string Sha256, IReadOnlyList<ExerciseRow> Rows);

public sealed class ExerciseFileRejectedException(string message) : Exception(message);

// The exercise list as a local file: fetched once from the source, checked, approved by its hash, then
// imported. The file stays outside the repository, because the source's content isn't ours to publish.
public static class ExerciseFile
{
    public const string Source = "https://oss.exercisedb.dev/";
    public const int MaxRows = 5000;
    private const int PageSize = 25;

    // The body parts the app knows. Anything else means the source changed, so the file is refused.
    public static readonly string[] BodyParts =
        ["chest", "back", "shoulders", "upper arms", "lower arms", "upper legs", "lower legs", "waist", "neck", "cardio"];

    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        WriteIndented = true,
        // keeps the text readable; the file is never put in a web page
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    // the same without indents, so the lists the database stores are compact
    private static readonly JsonSerializerOptions ImportJson = new(Json) { WriteIndented = false };

    // Reads every page of the source. Rows are sorted by id, so the hash only changes when the
    // source's content does.
    public static async Task<byte[]> FetchAsync(HttpClient client, Action<string> progress, CancellationToken cancellationToken = default)
    {
        var rows = new List<ExerciseRow>();
        string? cursor = null;

        do
        {
            var url = cursor is null
                ? $"api/v1/exercises?limit={PageSize}"
                : $"api/v1/exercises?limit={PageSize}&after={Uri.EscapeDataString(cursor)}";
            var page = await GetPageAsync(client, url, cancellationToken);

            rows.AddRange(page.Data.Select(item => new ExerciseRow(
                item.ExerciseId,
                item.Name,
                item.GifUrl,
                item.BodyParts.FirstOrDefault() ?? "",
                item.Instructions,
                item.Equipments,
                item.TargetMuscles,
                item.SecondaryMuscles)));
            progress($"{rows.Count} of {page.Meta!.Total}");

            cursor = page.Meta.HasNextPage
                ? page.Meta.NextCursor ?? throw new ExerciseFileRejectedException("The source says more pages exist but gave no cursor.")
                : null;
        } while (cursor is not null);

        var bytes = JsonSerializer.SerializeToUtf8Bytes(rows.OrderBy(r => r.Id, StringComparer.Ordinal).ToList(), Json);

        // the fetched file must pass the same checks as a file given to import
        Validate(bytes);
        return bytes;
    }

    private static async Task<ExerciseDbResponseDto> GetPageAsync(HttpClient client, string url, CancellationToken cancellationToken)
    {
        for (var attempt = 1; ; attempt++)
        {
            HttpResponseMessage sent;
            try
            {
                sent = await client.GetAsync(url, cancellationToken);
            }
            catch (HttpRequestException) when (attempt < 5)
            {
                // the source sometimes drops a connection; try the same page again
                await Task.Delay(TimeSpan.FromSeconds(2 * attempt), cancellationToken);
                continue;
            }

            using var response = sent;
            if ((int)response.StatusCode == 429 && attempt < 5)
            {
                await Task.Delay(TimeSpan.FromSeconds(5 * attempt), cancellationToken);
                continue;
            }

            response.EnsureSuccessStatusCode();
            var page = await response.Content.ReadFromJsonAsync<ExerciseDbResponseDto>(cancellationToken);
            if (page?.Meta is null || page.Data.Count == 0)
            {
                throw new ExerciseFileRejectedException($"The source returned an empty page for {url}.");
            }

            // stays well under the source's rate limit
            await Task.Delay(TimeSpan.FromMilliseconds(500), cancellationToken);
            return page;
        }
    }

    public static ValidatedExercises Validate(byte[] file)
    {
        List<ExerciseRow?>? rows;
        try
        {
            rows = JsonSerializer.Deserialize<List<ExerciseRow?>>(file, Json);
        }
        catch (JsonException ex)
        {
            throw new ExerciseFileRejectedException($"The file isn't a JSON list of exercises: {ex.Message}");
        }

        if (rows is null || rows.Count == 0 || rows.Count > MaxRows)
        {
            throw new ExerciseFileRejectedException($"The file must hold between 1 and {MaxRows} exercises.");
        }

        var ids = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var row in rows)
        {
            if (row is null || string.IsNullOrWhiteSpace(row.Id) || row.Id.Length > 450)
            {
                throw new ExerciseFileRejectedException($"An exercise has a missing or too long id: {row?.Id ?? "(none)"}.");
            }

            // the database compares ids without case, so these would clash
            if (!ids.Add(row.Id))
            {
                throw new ExerciseFileRejectedException($"The id {row.Id} appears more than once.");
            }

            if (string.IsNullOrWhiteSpace(row.Name) || row.Name.Length > 100)
            {
                throw new ExerciseFileRejectedException($"Exercise {row.Id} has a missing or too long name.");
            }

            if (!BodyParts.Contains(row.BodyPart))
            {
                throw new ExerciseFileRejectedException($"Exercise {row.Id} has an unknown body part: {row.BodyPart}.");
            }

            if (!Uri.TryCreate(row.GifUrl, UriKind.Absolute, out var gif) || gif.Scheme != Uri.UriSchemeHttps)
            {
                throw new ExerciseFileRejectedException($"Exercise {row.Id} has no https GIF link.");
            }

            if (row.Instructions is null || row.Instructions.Count == 0 || row.Instructions.Any(string.IsNullOrWhiteSpace))
            {
                throw new ExerciseFileRejectedException($"Exercise {row.Id} has missing instructions.");
            }

            foreach (var (label, list) in new[] { ("equipment", row.Equipments), ("target muscle", row.TargetMuscles), ("secondary muscle", row.SecondaryMuscles) })
            {
                if (list is not null && (list.Count > 50 || list.Any(term => string.IsNullOrWhiteSpace(term) || term.Length > 100)))
                {
                    throw new ExerciseFileRejectedException($"Exercise {row.Id} has a blank, too long or too many {label} terms.");
                }
            }
        }

        return new ValidatedExercises(Convert.ToHexString(SHA256.HashData(file)), rows!);
    }

    // The rows as the JSON the import statement reads with OPENJSON.
    internal static string ToImportJson(IReadOnlyList<ExerciseRow> rows) => JsonSerializer.Serialize(rows, ImportJson);
}
