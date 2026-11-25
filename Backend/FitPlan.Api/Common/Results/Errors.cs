
namespace FitPlan.Api.Common.Results;

// All the business errors the API can return, defined in one place.
public static class Errors
{
    // Auth
    public static readonly Error UsernameAlreadyExists =
        new("UsernameAlreadyExists", "Username is already taken.", ErrorType.Conflict);

    public static readonly Error InvalidCredentials =
        new("InvalidCredentials", "Invalid email, username or password.", ErrorType.Unauthorized);

    // Wrong, expired, used up or locked after too many tries. One message, so it reveals nothing.
    public static readonly Error InvalidEmailCode =
        new("InvalidEmailCode", "The code is wrong or has expired. Ask for a new one.", ErrorType.Validation);

    // Before a sign-up or email-change code is sent, and on a race between two sign-ups.
    public static readonly Error EmailAlreadyExists =
        new("EmailAlreadyExists", "This email already has an account.", ErrorType.Conflict);

    // A forgotten password for an address with no account.
    public static readonly Error EmailNotRegistered =
        new("EmailNotRegistered", "There's no account with this email.", ErrorType.NotFound);

    // Per address, on top of the per-IP limit, so nobody can use up the daily email allowance.
    public static readonly Error TooManyEmails =
        new("TooManyEmails", "Too many codes for this email. Wait a little and try again.", ErrorType.TooManyRequests);

    public static readonly Error EmailNotSent =
        new("EmailNotSent", "We couldn't send the email. Try again later.", ErrorType.ServiceUnavailable);

    // The refresh token is unknown, expired, revoked or was already used: the user must log in again.
    public static readonly Error InvalidRefreshToken =
        new("InvalidRefreshToken", "Your session has ended. Log in again.", ErrorType.Unauthorized);

    // Asked again while signed in. Not 401: that would end the session in the app.
    public static readonly Error WrongPassword =
        new("WrongPassword", "Your password is wrong.", ErrorType.Validation);

    // Users & Profile
    public static readonly Error UserNotFound =
        new("UserNotFound", "User not found.", ErrorType.NotFound);

    public static readonly Error InvalidFile =
        new("InvalidFile", "The uploaded file is invalid. Only JPG and PNG images are allowed.", ErrorType.Validation);

    public static readonly Error PictureNotFound =
        new("PictureNotFound", "There is no profile picture.", ErrorType.NotFound);

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

    // Other is kept for old entries only.
    public static readonly Error CardioMachineRetired =
        new("CardioMachineRetired", "Other can't be chosen any more. Pick the machine, or Swimming.", ErrorType.Validation);

    public static readonly Error CardioDistanceTooLong =
        new("CardioDistanceTooLong", "The distance can be at most 50,000 metres.", ErrorType.Validation);

    // Body Weight
    public static readonly Error SessionNotCompleted =
        new("SessionNotCompleted", "This workout session is still in progress.", ErrorType.Conflict);
    public static readonly Error NoExerciseHistory =
        new("NoExerciseHistory", "You have not done this exercise in a finished workout yet.", ErrorType.NotFound);
    public static readonly Error BodyWeightEntryNotFound =
        new("BodyWeightEntryNotFound", "Body weight entry not found.", ErrorType.NotFound);
}
