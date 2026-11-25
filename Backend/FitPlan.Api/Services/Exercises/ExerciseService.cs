using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.Exercises;

namespace FitPlan.Api.Services.Exercises;

// Reads from ExerciseCatalog, so browsing exercises doesn't touch the database.
// Comparisons ignore case, like the database's collation did. Search looks in the English name and,
// when the catalog has one, the Arabic name too, with Arabic spelling variants treated alike.
public class ExerciseService(ExerciseCatalog catalog, IConfiguration configuration) : IExerciseService
{
    // Body parts left out of the library and search (Phase 6: cardio, which Workout Session covers).
    // Only the listing hides them: their rows stay, and they still load by ID for old plans and history.
    // Clear the setting to bring them back.
    public const string HiddenBodyPartsSetting = "Exercises:HiddenBodyParts";

    // The order the filter chips show; a body part not listed here comes after them, A to Z.
    private static readonly string[] BodyPartOrder =
        ["chest", "back", "shoulders", "upper arms", "lower arms", "upper legs", "lower legs", "waist", "neck", "cardio"];

    private static readonly StringComparison IgnoreCase = StringComparison.OrdinalIgnoreCase;

    private readonly HashSet<string> _hidden = new(
        configuration.GetSection(HiddenBodyPartsSetting).Get<string[]>()?
            .Where(part => !string.IsNullOrWhiteSpace(part))
            .Select(part => part.Trim()) ?? [],
        StringComparer.OrdinalIgnoreCase);

    public async Task<ExerciseListResponseDto> GetAllExercisesAsync
    (
        int page, // to point on 1 page
        int pageSize,// to know how many exercises in the page
        string? bodyPart, // wish body part
        string? search, // to search with exercise name
        string language = ContentLanguage.English
    )
    {
        var snapshot = await catalog.GetAsync();
        IEnumerable<ExerciseDto> query = snapshot.All.Where(e => !_hidden.Contains(e.BodyPart));

        var hasSearch = !string.IsNullOrWhiteSpace(search);
        var ranks = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
        if (hasSearch)
        {
            // to bring the exercises that their name (in either language) contains the search
            var wanted = ArabicText.Normalize(search!.Trim());
            var arabic = snapshot.Languages.GetValueOrDefault(ContentLanguage.Arabic);
            foreach (var exercise in query)
            {
                var rank = Rank(ArabicText.Normalize(exercise.Name), wanted);
                if (arabic is not null && arabic.SearchNames.TryGetValue(exercise.Id, out var arabicName))
                {
                    rank = Math.Min(rank, Rank(arabicName, wanted));
                }

                if (rank < NoMatch)
                {
                    ranks[exercise.Id] = rank;
                }
            }

            query = query.Where(e => ranks.ContainsKey(e.Id));
        }

        if (!string.IsNullOrWhiteSpace(bodyPart))
        {
            // exact match, so "upper arms" does not also bring "lower arms"
            query = query.Where(e => e.BodyPart.Equals(bodyPart, IgnoreCase));
        }

        var matches = query.ToList();

        // the name as the app shows it, for the order
        var shown = snapshot.Languages.GetValueOrDefault(language);
        int ShownLength(ExerciseDto e) =>
            (shown is not null && shown.Exercises.TryGetValue(e.Id, out var text) ? text.Name : e.Name).Length;

        // with a search: the exact name first, then names that start with it, then the rest (shorter names first)
        var ordered = hasSearch
            ? matches
                .OrderBy(e => ranks[e.Id])
                .ThenBy(ShownLength)
                .ThenBy(e => e.Id, StringComparer.OrdinalIgnoreCase)
            : matches.OrderBy(e => e.Id, StringComparer.OrdinalIgnoreCase);

        // this is for put the exercises in pages
        var items = ordered
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(e => catalog.Localize(snapshot, e, language))
            .ToList();

        return new ExerciseListResponseDto
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            TotalCount = matches.Count,
            TotalPages = (int)Math.Ceiling((double)matches.Count / pageSize)
        };
    }

    // The body parts the library has, without the hidden ones: the app builds its filter chips from these.
    public async Task<IReadOnlyList<string>> GetBodyPartsAsync()
    {
        var snapshot = await catalog.GetAsync();

        return snapshot.All
            .Select(e => e.BodyPart.ToLowerInvariant())
            .Where(part => !_hidden.Contains(part))
            .Distinct()
            .OrderBy(part => Array.IndexOf(BodyPartOrder, part) is var index and >= 0 ? index : int.MaxValue)
            .ThenBy(part => part, StringComparer.Ordinal)
            .ToList();
    }

    // Hidden exercises too: a plan or a past workout may still point at one.
    public async Task<Result<ExerciseDto>> GetExerciseByIdAsync(string id, string language = ContentLanguage.English)
    {
        var snapshot = await catalog.GetAsync();

        return snapshot.ById.TryGetValue(id, out var exercise)
            ? Result<ExerciseDto>.Success(catalog.Localize(snapshot, exercise, language))
            : Result<ExerciseDto>.Failure(Errors.ExerciseNotFound);
    }

    private const int NoMatch = 4;

    // 0 the same name, 1 starts with the search, 2 has it somewhere, 3 has every word of it in any
    // order ("chest incline" finds "incline chest press"), NoMatch not at all
    private static int Rank(string name, string search) =>
        name.Equals(search, StringComparison.Ordinal) ? 0
        : name.StartsWith(search, StringComparison.Ordinal) ? 1
        : name.Contains(search, StringComparison.Ordinal) ? 2
        : search.Split(' ', StringSplitOptions.RemoveEmptyEntries).All(word => name.Contains(word, StringComparison.Ordinal)) ? 3
        : NoMatch;
}
