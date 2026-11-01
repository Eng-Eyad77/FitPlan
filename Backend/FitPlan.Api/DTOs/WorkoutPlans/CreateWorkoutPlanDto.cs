
using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.WorkoutPlans;

public class CreateWorkoutPlanDto
{
    [StringLength(100)]
    [Required]
    public required string Name { get; set; }

    [StringLength(500)]
    public string? Description { get; set; }
}
