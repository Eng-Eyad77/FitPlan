using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.Exercises;

namespace FitPlan.Api.Services.Exercises;

// Reads from ExerciseCatalog, so browsing exercises doesn't touch the database.
// Comparisons ignore case, like the database's collation did.
public class ExerciseService(ExerciseCatalog catalog) : IExerciseService
{
    private static readonly StringComparison IgnoreCase = StringComparison.OrdinalIgnoreCase;

    public async Task<ExerciseListResponseDto> GetAllExercisesAsync
    (
        int page, // to point on 1 page
        int pageSize,// to know how many exercises in the page
        string? bodyPart, // wish body part
        string? search // to search with exercise name
    )
    {
        var snapshot = await catalog.GetAsync();
        IEnumerable<ExerciseDto> query = snapshot.All;

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

    public async Task<Result<ExerciseDto>> GetExerciseByIdAsync(string id)
    {
        var snapshot = await catalog.GetAsync();

        return snapshot.ById.TryGetValue(id, out var exercise)
            ? Result<ExerciseDto>.Success(exercise)
            : Result<ExerciseDto>.Failure(Errors.ExerciseNotFound);
    }
}
