
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

    // Workout Sessions
    public static readonly Error WorkoutSessionNotFound =
        new("WorkoutSessionNotFound", "Workout session not found.", ErrorType.NotFound);

    public static readonly Error NoActiveSession =
        new("NoActiveSession", "There is no workout session in progress.", ErrorType.NotFound);

    public static readonly Error ActiveSessionExists =
        new("ActiveSessionExists", "You already have a workout session in progress.", ErrorType.Conflict);

    public static readonly Error SessionNotActive =
        new("SessionNotActive", "This workout session is already completed and cannot be changed.", ErrorType.Conflict);

    public static readonly Error EmptySession =
        new("EmptySession", "Log at least one set or cardio entry before finishing, or cancel the session.", ErrorType.Validation);

    // Session Exercises & Sets
    public static readonly Error SessionExerciseNotFound =
        new("SessionExerciseNotFound", "Exercise not found in this workout session.", ErrorType.NotFound);

    public static readonly Error ExerciseAlreadyInSession =
        new("ExerciseAlreadyInSession", "Exercise already exists in this workout session.", ErrorType.Conflict);

    public static readonly Error SetLimitReached =
        new("SetLimitReached", "An exercise can have at most 10 sets in one session.", ErrorType.Validation);

    public static readonly Error SessionSetNotFound =
        new("SessionSetNotFound", "Set not found.", ErrorType.NotFound);

    // Cardio
    public static readonly Error CardioEntryNotFound =
        new("CardioEntryNotFound", "Cardio entry not found.", ErrorType.NotFound);

    // Body Weight
    public static readonly Error SessionNotCompleted =
        new("SessionNotCompleted", "This workout session is still in progress.", ErrorType.Conflict);
    public static readonly Error NoExerciseHistory =
        new("NoExerciseHistory", "You have not done this exercise in a finished workout yet.", ErrorType.NotFound);
    public static readonly Error BodyWeightEntryNotFound =
        new("BodyWeightEntryNotFound", "Body weight entry not found.", ErrorType.NotFound);
}
