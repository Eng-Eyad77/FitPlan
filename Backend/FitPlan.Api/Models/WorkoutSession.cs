namespace FitPlan.Api.Models;

// One real training session: what the user actually did, not what the plan says.
public class WorkoutSession
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public User User { get; set; } = null!;

    // Optional: null for a quick workout, or when the plan was deleted later.
    public Guid? WorkoutPlanId { get; set; }

    public WorkoutPlan? WorkoutPlan { get; set; }

    // Copy of the plan name, so the history stays readable even if the plan is renamed or deleted.
    public required string Name { get; set; }

    public DateTime StartedAt { get; set; }

    // null = the session is still in progress.
    public DateTime? CompletedAt { get; set; }

    public string? Notes { get; set; }

    public ICollection<SessionExercise> Exercises { get; set; } = [];

    public ICollection<CardioEntry> CardioEntries { get; set; } = [];
}
