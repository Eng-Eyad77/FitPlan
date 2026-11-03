
using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.WorkoutSessions;

// Used for both adding and updating a set (same fields).
public class SessionSetRequestDto
{
    [Range(1, 100)]
    public int Reps { get; set; }

    // null = bodyweight exercise
    [Range(0.0, 500.0)]
    public decimal? WeightKg { get; set; }
}
