namespace FitPlan.Api.Models;

public class CardioEntry
{
    public Guid Id { get; set; }

    public Guid WorkoutSessionId { get; set; }

    public WorkoutSession WorkoutSession { get; set; } = null!;

    public CardioMachine Machine { get; set; }

    // Required. The app shows it in minutes.
    public int DurationSeconds { get; set; }

    // Optional details, the more the user gives the better the calorie estimate.
    public decimal? SpeedKmh { get; set; }

    public decimal? InclinePercent { get; set; }

    public decimal? DistanceKm { get; set; }

    // Calculated by the server when the entry is saved. null if the user has no body weight recorded.
    public int? EstimatedCalories { get; set; }

    public DateTime RecordedAt { get; set; }
}
