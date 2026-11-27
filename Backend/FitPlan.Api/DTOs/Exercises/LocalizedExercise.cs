namespace FitPlan.Api.DTOs.Exercises;

// A response that shows an exercise's name. ExerciseLanguageFilter puts the name in the request's
// language before the response is written, so the services that build these stay in English.
public interface ILocalizedExercise
{
    string ExerciseId { get; }

    string Name { get; set; }

    // the English name, set only when Name was translated
    string? EnglishName { get; set; }
}

// Also shows the exercise's steps.
public interface ILocalizedSteps : ILocalizedExercise
{
    List<string> Instructions { get; set; }
}

// A response that holds exercises further down. Implemented explicitly, so it isn't written to the JSON.
public interface IHasLocalizedExercises
{
    IEnumerable<ILocalizedExercise> LocalizedExercises { get; }
}
