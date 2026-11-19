namespace FitPlan.Api.Models;

public class SessionExercise
{
    public Guid Id { get; set; }

    public Guid WorkoutSessionId { get; set; }

    public WorkoutSession WorkoutSession { get; set; } = null!;

    public string ExerciseId { get; set; } = string.Empty;

    public Exercise Exercise { get; set; } = null!;

    public int Order { get; set; }

    // Copied from the plan as a reference for the user. null when added during the session.
    public int? TargetSets { get; set; }

    public int? TargetReps { get; set; }

    // Rest after each set, in seconds (15 to 600), copied from the plan and changeable during the session.
    // null = the app's default (90 s).
    public int? RestSeconds { get; set; }

    public ICollection<SessionSet> Sets { get; set; } = [];
}
