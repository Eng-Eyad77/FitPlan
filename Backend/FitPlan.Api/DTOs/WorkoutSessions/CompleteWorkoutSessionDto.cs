
using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.WorkoutSessions;

public class CompleteWorkoutSessionDto
{
    [StringLength(1000)]
    public string? Notes { get; set; }
}
