
namespace FitPlan.Api.DTOs.WorkoutSessions;

public class StartWorkoutSessionDto
{
    // null = quick workout (empty session)
    public Guid? WorkoutPlanId { get; set; }
}
