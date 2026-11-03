
using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.WorkoutSessions;

public class AddSessionExerciseDto
{
    [Required]
    public required string ExerciseId { get; set; }
}
