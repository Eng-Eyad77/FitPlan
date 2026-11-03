
namespace FitPlan.Api.DTOs.Profile;

public class ProfileDto
{
    public required Guid Id { get; set; }

    public required string Username { get; set; }

    public string? Bio  { get; set; }

    public string? ProfilePictureUrl { get; set; }

    // latest body weight entry, null if the user never recorded one
    public decimal? CurrentWeightKg { get; set; }

    // workouts per week the user aims for, null if not set
    public int? WeeklyGoal { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

}
