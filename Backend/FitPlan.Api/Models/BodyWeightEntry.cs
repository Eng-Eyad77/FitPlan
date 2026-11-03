namespace FitPlan.Api.Models;

// History of the user's body weight. The latest entry is the current weight.
public class BodyWeightEntry
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public User User { get; set; } = null!;

    public decimal WeightKg { get; set; }

    public DateTime RecordedAt { get; set; }
}
