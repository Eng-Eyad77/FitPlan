
namespace FitPlan.Api.DTOs.WorkoutPlanExercises;

public class WorkoutPlanExerciseResponseDto
{
    public Guid Id { get; set; }

    public required string ExerciseId { get; set; }

    public required string Name { get; set; }

    public required string GifUrl { get; set; }

    public required string BodyPart { get; set; }

    public required List<string> Instructions { get; set; }

    public int Sets { get; set; }
    public int Reps { get; set; }
    public int Order { get; set; }
}
