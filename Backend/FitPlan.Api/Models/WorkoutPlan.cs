namespace FitPlan.Api.Models;

public class WorkoutPlan
{
    public required Guid Id { get; set; }

    public required string Name { get; set; }

    public string? Description { get; set; }

    public Guid UserId {get; set; } 

    public User User { get; set; } = null!;
    
    public required DateTime CreatedAt { get; set; }

    public required DateTime UpdatedAt { get; set; }

}
