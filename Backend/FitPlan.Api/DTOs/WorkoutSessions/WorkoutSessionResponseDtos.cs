
using FitPlan.Api.Models;

namespace FitPlan.Api.DTOs.WorkoutSessions;

// The full session, used by the session screen.
public class WorkoutSessionResponseDto
{
    public Guid Id { get; set; }

    public required string Name { get; set; }

    public Guid? WorkoutPlanId { get; set; }

    public DateTime StartedAt { get; set; }

    public DateTime? CompletedAt { get; set; }

    public string? Notes { get; set; }

    public SessionExerciseResponseDto[] Exercises { get; set; } = [];

    public CardioEntryResponseDto[] Cardio { get; set; } = [];
}


public class SessionExerciseResponseDto
{
    public Guid Id { get; set; }

    public required string ExerciseId { get; set; }

    public required string Name { get; set; }

    public required string GifUrl { get; set; }

    public required string BodyPart { get; set; }

    public int Order { get; set; }

    public int? TargetSets { get; set; }

    public int? TargetReps { get; set; }

    public SessionSetResponseDto[] Sets { get; set; } = [];

    // what the user did the last time with this exercise ("آخر مرة").
    // Only filled while the session is in progress, null if never done before.
    public LastPerformanceDto? LastPerformance { get; set; }

    // what to try today, from the last time. Same lifetime as LastPerformance.
    public SuggestionDto? Suggestion { get; set; }
}


public class SessionSetResponseDto
{
    public Guid Id { get; set; }

    public int SetNumber { get; set; }

    public int Reps { get; set; }

    public decimal? WeightKg { get; set; }
}


public class LastPerformanceDto
{
    public DateTime PerformedAt { get; set; }

    public SessionSetResponseDto[] Sets { get; set; } = [];
}


public enum SuggestionReason
{
    IncreaseWeight = 1, // every target rep was hit last time
    RepeatWeight,       // same weight, beat the reps
    Deload,             // two weak workouts in a row
    MoreReps            // bodyweight exercise
}


public class SuggestionDto
{
    // null for a bodyweight exercise
    public decimal? WeightKg { get; set; }

    public int Reps { get; set; }

    public SuggestionReason Reason { get; set; }
}


public class CardioEntryResponseDto
{
    public Guid Id { get; set; }

    public CardioMachine Machine { get; set; }

    public int DurationSeconds { get; set; }

    public decimal? SpeedKmh { get; set; }

    public decimal? InclinePercent { get; set; }

    public decimal? DistanceKm { get; set; }

    // an estimate, null if the user has no body weight recorded
    public int? EstimatedCalories { get; set; }
}


// A short version of a completed session, used by the history list and the summary screen.
public class WorkoutSessionSummaryDto
{
    public Guid Id { get; set; }

    public required string Name { get; set; }

    public DateTime StartedAt { get; set; }

    public DateTime CompletedAt { get; set; }

    public int DurationSeconds { get; set; }

    public int ExerciseCount { get; set; }

    public int SetCount { get; set; }

    // sum of (reps × weight) of all sets
    public decimal TotalVolumeKg { get; set; }

    public int CardioDurationSeconds { get; set; }

    public int EstimatedCalories { get; set; }
}
