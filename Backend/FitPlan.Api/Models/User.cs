using System;

namespace FitPlan.Api.Models;

public class User
{
    public required Guid Id { get; set; }

    public required string Username { get; set; }

    public required string PasswordHash { get; set; }

    public string? Bio { get; set; }

    public ICollection<WorkoutPlan> WorkoutPlans { get; set; } = [];

    public string? ProfilePictureUrl { get; set; }

    // Workouts per week the user aims for (1-7). null = no goal set.
    public int? WeeklyGoal { get; set; }

    public required DateTime CreatedAt { get; set; }

    public required DateTime UpdatedAt { get; set; }
}
