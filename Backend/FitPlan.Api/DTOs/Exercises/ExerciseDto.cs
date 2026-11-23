namespace FitPlan.Api.DTOs.Exercises;

public record class ExerciseDto
{
    public required string Id { get; set; }

    public required string Name { get; set; }

    // the English name when Name is in another language, so the app can show both
    public string? EnglishName { get; set; }

    public  required string GifUrl { get; set; }

    // stays the English key in every language: the app names body parts itself, and filters by this
    public  required string BodyPart { get; set; }

    public required List<string> Instructions { get; set; }

    // Phase 11C: in the request's language, empty when the details aren't imported yet
    public List<string> Equipments { get; set; } = [];

    public List<string> TargetMuscles { get; set; } = [];

    public List<string> SecondaryMuscles { get; set; } = [];
}
