namespace FitPlan.Api.Models;

public class WorkoutPlanExercise
{
     public Guid Id { get; set; }

      public Guid WorkoutPlanId { get; set; }


      public string ExerciseId { get; set; } = String.Empty;

      public int Sets { get; set; }

      public int Reps { get; set; }

      public int Order { get; set; }
}
