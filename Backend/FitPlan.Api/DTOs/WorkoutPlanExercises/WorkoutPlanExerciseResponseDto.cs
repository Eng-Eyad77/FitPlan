
using FitPlan.Api.DTOs.Exercises;

namespace FitPlan.Api.DTOs.WorkoutPlanExercises;

public class WorkoutPlanExerciseResponseDto : ILocalizedSteps
{
    public Guid Id { get; set; }

    public required string ExerciseId { get; set; }

    public required string Name { get; set; }

    // the English name when Name is in another language, so the app can show both
    public string? EnglishName { get; set; }

    public required string GifUrl { get; set; }

    public required string BodyPart { get; set; }

    public required List<string> Instructions { get; set; }

    public int Sets { get; set; }
    public int Reps { get; set; }
    public int Order { get; set; }

    public int? RestSeconds { get; set; }
    public string? Note { get; set; }
}
