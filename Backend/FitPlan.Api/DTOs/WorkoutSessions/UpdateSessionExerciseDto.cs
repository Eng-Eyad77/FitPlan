using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.WorkoutSessions;

// Changes an exercise for this session only. The plan is not changed.
public class UpdateSessionExerciseDto
{
    // Rest after each set, in seconds. null = the app's default (90 s).
    [Range(15, 600)]
    public int? RestSeconds { get; set; }
}
