using System.Security.Cryptography;
using System.Text.Encodings.Web;
using System.Text.Json;

namespace FitPlan.Migrator;

public sealed record TranslatedExercise(string Name, List<string> Instructions);

public sealed record ValidatedTranslations(
    string Sha256,
    string Language,
    IReadOnlyDictionary<string, TranslatedExercise> Exercises,
    IReadOnlyDictionary<string, IReadOnlyDictionary<string, string>> Terms);

// Phase 11C: one language's exercise text as a local file, approved by its hash and then imported.
// Like the exercise list, it stays outside the repository: it is a translation of the source's content.
//
//   { "version": 1, "language": "ar",
//     "terms": { "equipment": { "barbell": "بار" }, "muscle": { "biceps": "البايسبس" } },
//     "exercises": { "<exercise id>": { "name": "...", "instructions": ["...", "..."] } } }
public static class TranslationFile
{
    public const int Version = 1;
    public static readonly string[] Languages = ["ar"];
    public static readonly string[] TermKinds = ["equipment", "muscle"];

    private sealed record Pack(
        int Version,
        string? Language,
        Dictionary<string, Dictionary<string, string>>? Terms,
        Dictionary<string, TranslatedExercise?>? Exercises);

    private static readonly JsonSerializerOptions Read = new(JsonSerializerDefaults.Web);

    // compact and unescaped, so the lists are stored as readable Arabic, the way the API reads them
    private static readonly JsonSerializerOptions Write = new() { Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping };

    public static ValidatedTranslations Validate(byte[] file)
    {
        Pack? pack;
        try
        {
            pack = JsonSerializer.Deserialize<Pack>(file, Read);
        }
        catch (JsonException ex)
        {
            throw new ExerciseFileRejectedException($"The file isn't a translation file: {ex.Message}");
        }

        if (pack is null || pack.Version != Version)
        {
            throw new ExerciseFileRejectedException($"The file must be a version {Version} translation file.");
        }

        if (pack.Language is null || !Languages.Contains(pack.Language))
        {
            throw new ExerciseFileRejectedException($"The language must be one of: {string.Join(", ", Languages)}.");
        }

        if (pack.Exercises is null || pack.Exercises.Count == 0 || pack.Exercises.Count > ExerciseFile.MaxRows)
        {
            throw new ExerciseFileRejectedException($"The file must hold between 1 and {ExerciseFile.MaxRows} exercises.");
        }

        var ids = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var (id, exercise) in pack.Exercises)
        {
            if (string.IsNullOrWhiteSpace(id) || id.Length > 450 || !ids.Add(id))
            {
                throw new ExerciseFileRejectedException($"The exercise id {id} is missing, too long, or appears more than once.");
            }

            if (exercise is null || string.IsNullOrWhiteSpace(exercise.Name) || exercise.Name.Length > 150)
            {
                throw new ExerciseFileRejectedException($"Exercise {id} has a missing or too long name.");
            }

            if (exercise.Instructions is null || exercise.Instructions.Count == 0 || exercise.Instructions.Any(string.IsNullOrWhiteSpace))
            {
                throw new ExerciseFileRejectedException($"Exercise {id} has missing instructions.");
            }
        }

        var terms = pack.Terms ?? [];
        foreach (var (kind, words) in terms)
        {
            if (!TermKinds.Contains(kind))
            {
                throw new ExerciseFileRejectedException($"Unknown term kind {kind}. Known: {string.Join(", ", TermKinds)}.");
            }

            foreach (var (term, text) in words)
            {
                if (string.IsNullOrWhiteSpace(term) || term.Length > 100 || string.IsNullOrWhiteSpace(text) || text.Length > 150)
                {
                    throw new ExerciseFileRejectedException($"The {kind} term {term} has a missing or too long word.");
                }
            }
        }

        return new ValidatedTranslations(
            Convert.ToHexString(SHA256.HashData(file)),
            pack.Language,
            pack.Exercises.ToDictionary(e => e.Key, e => e.Value!),
            terms.ToDictionary(t => t.Key, t => (IReadOnlyDictionary<string, string>)t.Value));
    }

    // The rows and terms as the JSON the import statements read with OPENJSON.
    internal static string ToImportJson(ValidatedTranslations pack) => JsonSerializer.Serialize(
        pack.Exercises.Select(e => new { id = e.Key, name = e.Value.Name, instructions = e.Value.Instructions }), Write);

    internal static string TermsToImportJson(ValidatedTranslations pack) => JsonSerializer.Serialize(
        pack.Terms.SelectMany(kind => kind.Value.Select(t => new { kind = kind.Key, term = t.Key, text = t.Value })), Write);
}
