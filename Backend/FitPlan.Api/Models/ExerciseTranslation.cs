namespace FitPlan.Api.Models;

// An exercise's name and steps in another language. English stays on the Exercise row itself.
public class ExerciseTranslation
{
    public required string ExerciseId { get; set; }

    // a language code such as "ar"
    public required string Language { get; set; }

    public required string Name { get; set; }

    public required List<string> Instructions { get; set; }

    // false until a person has read the translation through
    public bool Reviewed { get; set; }

    public Exercise Exercise { get; set; } = null!;
}
