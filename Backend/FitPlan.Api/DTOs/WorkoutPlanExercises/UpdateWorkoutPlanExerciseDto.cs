
using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.WorkoutPlanExercises;

public class UpdateWorkoutPlanExerciseDto
{
      [Range(1,4)]
    public int Sets { get; set; }


    [Range(1,20)]
    public int Reps { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "The value must be greater than 0.")]
    public int Order { get; set; }

    // Rest after each set, in seconds. null = the app's default (90 s).
    [Range(15, 600)]
    public int? RestSeconds { get; set; }
}
