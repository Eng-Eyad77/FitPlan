namespace FitPlan.Api.Models;

public class SessionSet
{
    public Guid Id { get; set; }

    public Guid SessionExerciseId { get; set; }

    public SessionExercise SessionExercise { get; set; } = null!;

    public int SetNumber { get; set; }

    public int Reps { get; set; }

    // null = bodyweight exercise (push-ups, pull-ups...).
    public decimal? WeightKg { get; set; }
}
