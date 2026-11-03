namespace FitPlan.Api.DTOs.WorkoutPlans;

public class WorkoutPlanResponseDto
{
    public Guid Id { get; set; }

    public  required string Name { get; set; }

    public string? Description { get; set; }

    public required DateTime CreatedAt { get; set; }

    public required DateTime UpdatedAt { get; set; }

    // shown on the plan cards in the app
    public int ExerciseCount { get; set; }

}
