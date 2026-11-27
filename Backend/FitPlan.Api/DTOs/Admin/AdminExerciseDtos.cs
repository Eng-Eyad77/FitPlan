using System.ComponentModel.DataAnnotations;
using FitPlan.Api.Services.Exercises;

namespace FitPlan.Api.DTOs.Admin;

// 12C
public record AdminExerciseRowDto(string Id, string Name, string? ArabicName, string BodyPart, bool Hidden, GifStatus? GifStatus);

public record AdminExerciseCountsDto(int All, int NoDemo, int NotChecked, int Hidden);

public record AdminExerciseListDto(AdminExerciseRowDto[] Items, int Page, int TotalPages, int TotalCount, AdminExerciseCountsDto Counts);

public record AdminExerciseDetailDto(
    string Id,
    string BodyPart,
    string GifUrl,
    GifStatus? GifStatus,
    DateTime? GifCheckedAt,
    bool Hidden,
    string EnglishName,
    List<string> EnglishInstructions,
    string? ArabicName,
    List<string>? ArabicInstructions,
    int Plans,
    int Workouts);

// Both languages together: an exercise is never saved with only one (roadmap rule 12).
public class AdminExerciseTextDto
{
    [Required, StringLength(100, MinimumLength = 2)]
    public required string EnglishName { get; set; }

    [Required, MinLength(1), MaxLength(20)]
    public required List<string> EnglishInstructions { get; set; }

    [Required, StringLength(150, MinimumLength = 2)]
    public required string ArabicName { get; set; }

    [Required, MinLength(1), MaxLength(20)]
    public required List<string> ArabicInstructions { get; set; }
}

public class AdminGifCheckRequestDto
{
    // exercises in id order, from this position
    [Range(0, 100_000)]
    public int Offset { get; set; }

    [Range(1, AdminGifCheckLimits.MaxBatch)]
    public int Count { get; set; } = AdminGifCheckLimits.MaxBatch;
}

public static class AdminGifCheckLimits
{
    // about 10 seconds a batch, well inside a request's time
    public const int MaxBatch = 40;
}

public record AdminGifCheckResultDto(int Checked, int NextOffset, int Total, int Broken, int Unreachable);
