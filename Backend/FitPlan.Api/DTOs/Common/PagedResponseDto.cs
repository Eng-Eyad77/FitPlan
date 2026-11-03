
namespace FitPlan.Api.DTOs.Common;

// Same shape as ExerciseListResponseDto, so the client reads every paged list the same way.
public class PagedResponseDto<T>
{
    public T[] Items { get; set; } = [];

    public int Page { get; set; }

    public int PageSize { get; set; }

    public int TotalCount { get; set; }

    public int TotalPages { get; set; }
}
