using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Profile;

public class UpdateWeeklyGoalDto
{
    // null removes the goal
    [Range(1, 7)]
    public int? WeeklyGoal { get; set; }
}
