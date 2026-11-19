using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.Exercises;

namespace FitPlan.Api.Services.Exercises;

// Reads from ExerciseCatalog, so browsing exercises doesn't touch the database.
// Comparisons ignore case, like the database's collation did.
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
        string? search // to search with exercise name
    )
    {
        var snapshot = await catalog.GetAsync();
        IEnumerable<ExerciseDto> query = snapshot.All.Where(e => !_hidden.Contains(e.BodyPart));

        var hasSearch = !string.IsNullOrWhiteSpace(search);
        if (hasSearch)
        {
            // to bring the exercises that their name contains the search
            query = query.Where(e => e.Name.Contains(search!, IgnoreCase));
        }

        if (!string.IsNullOrWhiteSpace(bodyPart))
        {
            // exact match, so "upper arms" does not also bring "lower arms"
            query = query.Where(e => e.BodyPart.Equals(bodyPart, IgnoreCase));
        }

        var matches = query.ToList();

        // with a search: the exact name first, then names that start with it, then the rest (shorter names first)
        var ordered = hasSearch
            ? matches
                .OrderBy(e => e.Name.Equals(search, IgnoreCase) ? 0 : e.Name.StartsWith(search!, IgnoreCase) ? 1 : 2)
                .ThenBy(e => e.Name.Length)
                .ThenBy(e => e.Id, StringComparer.OrdinalIgnoreCase)
            : matches.OrderBy(e => e.Id, StringComparer.OrdinalIgnoreCase);

        // this is for put the exercises in pages
        var items = ordered
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
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
    public async Task<Result<ExerciseDto>> GetExerciseByIdAsync(string id)
    {
        var snapshot = await catalog.GetAsync();

        return snapshot.ById.TryGetValue(id, out var exercise)
            ? Result<ExerciseDto>.Success(exercise)
            : Result<ExerciseDto>.Failure(Errors.ExerciseNotFound);
    }
}
