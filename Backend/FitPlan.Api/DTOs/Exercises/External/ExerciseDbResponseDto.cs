namespace FitPlan.Api.DTOs.Exercises.External;

public class ExerciseDbResponseDto
{
    public ExerciseDbMetaDto? Meta { get; set; }

    public List<ExerciseDbItemDto> Data { get; set; } = [];
}

public class ExerciseDbMetaDto
{
    public int Total { get; set; }

    public bool HasNextPage { get; set; }

    public bool HasPreviousPage { get; set; }

    public string? NextCursor { get; set; }
}

public class ExerciseDbItemDto
{
    public required string ExerciseId { get; set; }

    public required string Name { get; set; }

    public required string GifUrl { get; set; }

    public List<string> BodyParts { get; set; } = [];

    public List<string> Instructions { get; set; } = [];
}