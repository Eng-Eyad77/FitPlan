namespace FitPlan.Api.Models;

public class WorkoutPlanExercise
{
     public Guid Id { get; set; }

      public Guid WorkoutPlanId { get; set; }


      public string ExerciseId { get; set; } = String.Empty;

      public int Sets { get; set; }

      public int Reps { get; set; }

      // Rest after each set, in seconds (15 to 600). null = the app's default (90 s).
      public int? RestSeconds { get; set; }
      // the user's own reminder, e.g. "seat on 4". Shown and changeable in a workout; a change made
      // there comes back here when the workout is finished.
      public string? Note { get; set; }

      public int Order { get; set; }
      
      public WorkoutPlan WorkoutPlan { get; set; } = null!;

      public Exercise Exercise { get; set; } = null!;

}
