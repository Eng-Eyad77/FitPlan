namespace FitPlan.Api.DTOs.WorkoutPlans;

public class WorkoutPlanResponseDto
{
    public Guid Id { get; set; }

    public  required string Name { get; set; }

    public string? Description { get; set; }

    public required DateTime CreatedAt { get; set; }

    public required DateTime UpdatedAt { get; set; }

}
