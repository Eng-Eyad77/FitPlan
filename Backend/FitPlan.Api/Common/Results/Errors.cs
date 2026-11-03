
namespace FitPlan.Api.Common.Results;

// All the business errors the API can return, defined in one place.
public static class Errors
{
    // Auth
    public static readonly Error UsernameAlreadyExists =
        new("UsernameAlreadyExists", "Username is already taken.", ErrorType.Conflict);

    public static readonly Error InvalidCredentials =
        new("InvalidCredentials", "Invalid username or password.", ErrorType.Unauthorized);

    // Users & Profile
    public static readonly Error UserNotFound =
        new("UserNotFound", "User not found.", ErrorType.NotFound);

    public static readonly Error InvalidFile =
        new("InvalidFile", "The uploaded file is invalid. Only JPG and PNG images are allowed.", ErrorType.Validation);

    public static readonly Error FileTooLarge =
        new("FileTooLarge", "The file size exceeds the 5 MB limit.", ErrorType.PayloadTooLarge);

    // Exercises
    public static readonly Error ExerciseNotFound =
        new("ExerciseNotFound", "Exercise not found.", ErrorType.NotFound);

    // Workout Plans
    public static readonly Error WorkoutPlanNotFound =
        new("WorkoutPlanNotFound", "Workout plan not found.", ErrorType.NotFound);

    // Workout Plan Exercises
    public static readonly Error ExerciseAlreadyExists =
        new("ExerciseAlreadyExists", "Exercise already exists in this workout plan.", ErrorType.Conflict);

    public static readonly Error WorkoutPlanExerciseNotFound =
        new("WorkoutPlanExerciseNotFound", "Workout plan exercise not found.", ErrorType.NotFound);
}
