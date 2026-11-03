
using System.Linq.Expressions;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.WorkoutSessions;

// Entity -> DTO mapping shared by the session, session exercise and cardio services.
public static class WorkoutSessionMappings
{
    // Expects Exercises (with Exercise and Sets) and CardioEntries to be loaded.
    public static WorkoutSessionResponseDto ToSessionDto(
        WorkoutSession session,
        IReadOnlyDictionary<string, ExerciseHistory> history) => new()
    {
        Id = session.Id,
        Name = session.Name,
        WorkoutPlanId = session.WorkoutPlanId,
        StartedAt = session.StartedAt,
        CompletedAt = session.CompletedAt,
        Notes = session.Notes,
        Exercises = session.Exercises
            .OrderBy(e => e.Order)
            .Select(e => ToExerciseDto(e, history.GetValueOrDefault(e.ExerciseId)))
            .ToArray(),
        Cardio = session.CardioEntries
            .OrderBy(c => c.RecordedAt)
            .Select(ToCardioDto)
            .ToArray()
    };

    // Expects Exercise and Sets to be loaded.
    public static SessionExerciseResponseDto ToExerciseDto(SessionExercise sessionExercise, ExerciseHistory? history) => new()
    {
        Id = sessionExercise.Id,
        ExerciseId = sessionExercise.ExerciseId,
        Name = sessionExercise.Exercise.Name,
        GifUrl = sessionExercise.Exercise.GifUrl,
        BodyPart = sessionExercise.Exercise.BodyPart,
        Order = sessionExercise.Order,
        TargetSets = sessionExercise.TargetSets,
        TargetReps = sessionExercise.TargetReps,
        Sets = sessionExercise.Sets
            .OrderBy(s => s.SetNumber)
            .Select(ToSetDto)
            .ToArray(),
        LastPerformance = history?.Last,
        Suggestion = history is null
            ? null
            : OverloadRules.Suggest(
                sessionExercise.Exercise.Name,
                sessionExercise.Exercise.BodyPart,
                sessionExercise.TargetSets,
                sessionExercise.TargetReps,
                history.Last.Sets,
                history.PreviousSets)
    };

    public static SessionSetResponseDto ToSetDto(SessionSet set) => new()
    {
        Id = set.Id,
        SetNumber = set.SetNumber,
        Reps = set.Reps,
        WeightKg = set.WeightKg
    };

    public static CardioEntryResponseDto ToCardioDto(CardioEntry cardio) => new()
    {
        Id = cardio.Id,
        Machine = cardio.Machine,
        DurationSeconds = cardio.DurationSeconds,
        SpeedKmh = cardio.SpeedKmh,
        InclinePercent = cardio.InclinePercent,
        DistanceKm = cardio.DistanceKm,
        EstimatedCalories = cardio.EstimatedCalories
    };


    // An Expression (not a normal method) so EF translates it to SQL:
    // the counts and sums are calculated by the database, without loading every set.
    // Only valid for completed sessions.
    public static readonly Expression<Func<WorkoutSession, WorkoutSessionSummaryDto>> ToSummaryDto = s => new WorkoutSessionSummaryDto
    {
        Id = s.Id,
        Name = s.Name,
        StartedAt = s.StartedAt,
        CompletedAt = s.CompletedAt!.Value,
        DurationSeconds = EF.Functions.DateDiffSecond(s.StartedAt, s.CompletedAt!.Value),
        ExerciseCount = s.Exercises.Count(),
        SetCount = s.Exercises.SelectMany(e => e.Sets).Count(),
        TotalVolumeKg = s.Exercises.SelectMany(e => e.Sets).Sum(set => set.Reps * (set.WeightKg ?? 0)),
        CardioDurationSeconds = s.CardioEntries.Sum(c => c.DurationSeconds),
        EstimatedCalories = s.CardioEntries.Sum(c => c.EstimatedCalories ?? 0)
    };
}
