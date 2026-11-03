using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Stats;
using FitPlan.Api.Services.WorkoutSessions;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.Stats;

// Progress numbers, all calculated from the completed workouts (nothing extra is stored).
//
// Records and charts load the user's sets into memory and calculate there:
// simple and fine for one person's history (thousands of sets). If it ever gets slow,
// the records can be stored and updated when a workout is finished.
public class StatsService(FitPlanDbContext context) : IStatsService
{
    public async Task<Result<StatsOverviewDto>> GetOverviewAsync(Guid userId, StatsOverviewQuery query)
    {
        var user = await context.Users
            .AsNoTracking()
            .Where(u => u.Id == userId)
            .Select(u => new { u.WeeklyGoal })
            .FirstOrDefaultAsync();

        if (user is null)
        {
            return Result<StatsOverviewDto>.Failure(Errors.UserNotFound);
        }

        var sessions = await context.WorkoutSessions
            .AsNoTracking()
            .Where(s => s.UserId == userId && s.CompletedAt != null)
            .Select(WorkoutSessionMappings.ToSummaryDto)
            .ToListAsync();

        var offset = TimeSpan.FromMinutes(query.UtcOffsetMinutes);
        DateOnly WeekOf(DateTime utc) =>
            RecordMath.WeekStart(DateOnly.FromDateTime(utc + offset), query.WeekStartsOn);

        var byWeek = sessions
            .GroupBy(s => WeekOf(s.CompletedAt))
            .ToDictionary(group => group.Key, group => new WeekStatsDto
            {
                WeekStart = group.Key,
                Workouts = group.Count(),
                Sets = group.Sum(s => s.SetCount),
                VolumeKg = group.Sum(s => s.TotalVolumeKg),
                CardioSeconds = group.Sum(s => s.CardioDurationSeconds),
                EstimatedCalories = group.Sum(s => s.EstimatedCalories)
            });

        var thisWeek = WeekOf(DateTime.UtcNow);
        WeekStatsDto Week(DateOnly start) => byWeek.GetValueOrDefault(start) ?? new WeekStatsDto { WeekStart = start };

        return Result<StatsOverviewDto>.Success(new StatsOverviewDto
        {
            WeeklyGoal = user.WeeklyGoal,
            CurrentStreakWeeks = Streak(byWeek, thisWeek, user.WeeklyGoal ?? 1),
            TotalWorkouts = sessions.Count,
            ThisWeek = Week(thisWeek),
            LastWeek = Week(thisWeek.AddDays(-7)),
            Weeks = Enumerable.Range(0, query.Weeks)
                .Select(i => Week(thisWeek.AddDays(-7 * (query.Weeks - 1 - i))))
                .ToArray()
        });
    }

    // Weeks in a row with at least [goal] workouts, counting back from the current week.
    // The current week is still open: not reaching the goal yet does not break the streak.
    private static int Streak(Dictionary<DateOnly, WeekStatsDto> byWeek, DateOnly thisWeek, int goal)
    {
        bool Reached(DateOnly week) => byWeek.TryGetValue(week, out var stats) && stats.Workouts >= goal;

        var streak = Reached(thisWeek) ? 1 : 0;
        for (var week = thisWeek.AddDays(-7); Reached(week); week = week.AddDays(-7))
        {
            streak++;
        }

        return streak;
    }


    public async Task<ExerciseRecordsDto[]> GetRecordsAsync(Guid userId)
    {
        var sets = await LoadSetsAsync(userId);
        var exercises = await LoadExerciseInfoAsync(sets.Select(s => s.ExerciseId).Distinct().ToList());

        return sets
            .GroupBy(s => s.ExerciseId)
            .Where(group => exercises.ContainsKey(group.Key))
            .Select(group => ToRecords(exercises[group.Key], group.ToList()))
            .OrderByDescending(r => r.LastPerformedAt) // the exercises trained recently first
            .ToArray();
    }


    public async Task<Result<ExerciseProgressDto>> GetExerciseProgressAsync(Guid userId, string exerciseId)
    {
        var exercises = await LoadExerciseInfoAsync([exerciseId]);

        if (!exercises.TryGetValue(exerciseId, out var exercise))
        {
            return Result<ExerciseProgressDto>.Failure(Errors.ExerciseNotFound);
        }

        var sets = await LoadSetsAsync(userId, [exerciseId]);

        if (sets.Count == 0)
        {
            return Result<ExerciseProgressDto>.Failure(Errors.NoExerciseHistory);
        }

        return Result<ExerciseProgressDto>.Success(new ExerciseProgressDto
        {
            Records = ToRecords(exercise, sets),
            Sessions = sets
                .GroupBy(s => s.SessionId)
                .Select(group =>
                {
                    var top = RecordMath.TopSet(group);
                    return new ExerciseSessionPointDto
                    {
                        SessionId = group.Key,
                        PerformedAt = group.First().CompletedAt,
                        TopSetWeightKg = top.WeightKg,
                        TopSetReps = top.Reps,
                        Estimated1Rm = RecordMath.BestEstimated1Rm(group)?.Value,
                        VolumeKg = group.Sum(s => RecordMath.Volume(s.WeightKg, s.Reps)),
                        Sets = group.Count()
                    };
                })
                .OrderBy(point => point.PerformedAt)
                .ToArray()
        });
    }


    public async Task<Result<SessionComparisonDto>> GetSessionComparisonAsync(Guid userId, Guid sessionId)
    {
        var session = await context.WorkoutSessions
            .AsNoTracking()
            .Where(s => s.Id == sessionId && s.UserId == userId)
            .Select(s => new { s.Id, s.Name, s.WorkoutPlanId, s.StartedAt, s.CompletedAt })
            .FirstOrDefaultAsync();

        if (session is null)
        {
            return Result<SessionComparisonDto>.Failure(Errors.WorkoutSessionNotFound);
        }

        if (session.CompletedAt is not { } completedAt)
        {
            return Result<SessionComparisonDto>.Failure(Errors.SessionNotCompleted);
        }

        // the previous run of the same plan; a quick workout compares with one of the same name
        var earlier = context.WorkoutSessions
            .AsNoTracking()
            .Where(s => s.UserId == userId && s.CompletedAt != null && s.CompletedAt < completedAt);

        earlier = session.WorkoutPlanId is { } planId
            ? earlier.Where(s => s.WorkoutPlanId == planId)
            : earlier.Where(s => s.WorkoutPlanId == null && s.Name == session.Name);

        var previous = await earlier
            .OrderByDescending(s => s.CompletedAt)
            .Select(s => new { s.Id, s.StartedAt, CompletedAt = s.CompletedAt!.Value })
            .FirstOrDefaultAsync();

        var currentSets = await LoadSetsOfSessionAsync(session.Id);
        var exerciseIds = currentSets.Select(s => s.ExerciseId).Distinct().ToList();
        var exercises = await LoadExerciseInfoAsync(exerciseIds);

        // everything done before this workout, for the records
        var setsBefore = await LoadSetsAsync(userId, exerciseIds, before: completedAt);
        var previousSets = previous is null
            ? []
            : setsBefore.Where(s => s.SessionId == previous.Id).ToList();

        var exerciseComparisons = new List<ExerciseComparisonDto>();
        var newRecords = new List<NewRecordDto>();

        foreach (var group in currentSets.GroupBy(s => s.ExerciseId))
        {
            var name = exercises.GetValueOrDefault(group.Key)?.Name ?? group.Key;
            var current = group.ToList();
            var top = RecordMath.TopSet(current);
            var previousOfExercise = previousSets.Where(s => s.ExerciseId == group.Key).ToList();
            var previousTop = previousOfExercise.Count == 0 ? null : RecordMath.TopSet(previousOfExercise);

            exerciseComparisons.Add(new ExerciseComparisonDto
            {
                ExerciseId = group.Key,
                Name = name,
                TopSetWeightKg = top.WeightKg,
                TopSetReps = top.Reps,
                PreviousTopSetWeightKg = previousTop?.WeightKg,
                PreviousTopSetReps = previousTop?.Reps,
                VolumeKg = current.Sum(s => RecordMath.Volume(s.WeightKg, s.Reps)),
                PreviousVolumeKg = previousOfExercise.Count == 0
                    ? null
                    : previousOfExercise.Sum(s => RecordMath.Volume(s.WeightKg, s.Reps))
            });

            var before = setsBefore.Where(s => s.ExerciseId == group.Key).ToList();
            newRecords.AddRange(RecordMath.NewRecords(current, before).Select(record => new NewRecordDto
            {
                ExerciseId = group.Key,
                Name = name,
                Type = record.Type,
                Value = record.Value,
                PreviousBest = record.PreviousBest
            }));
        }

        return Result<SessionComparisonDto>.Success(new SessionComparisonDto
        {
            SessionId = session.Id,
            PreviousSessionId = previous?.Id,
            PreviousPerformedAt = previous?.CompletedAt,
            VolumeKg = new ComparedValueDto
            {
                Current = currentSets.Sum(s => RecordMath.Volume(s.WeightKg, s.Reps)),
                Previous = previous is null ? null : previousSets.Sum(s => RecordMath.Volume(s.WeightKg, s.Reps))
            },
            Sets = new ComparedValueDto
            {
                Current = currentSets.Count,
                Previous = previous is null ? null : previousSets.Count
            },
            DurationSeconds = new ComparedValueDto
            {
                Current = (decimal)(completedAt - session.StartedAt).TotalSeconds,
                Previous = previous is null ? null : (decimal)(previous.CompletedAt - previous.StartedAt).TotalSeconds
            },
            Exercises = exerciseComparisons.ToArray(),
            NewRecords = newRecords.ToArray()
        });
    }


    // ---------- loading ----------

    // The sets of the user's completed workouts, optionally only some exercises and only before a date.
    private Task<List<SetRow>> LoadSetsAsync(
        Guid userId,
        IReadOnlyCollection<string>? exerciseIds = null,
        DateTime? before = null)
    {
        var query = context.SessionSets
            .AsNoTracking()
            .Where(s => s.SessionExercise.WorkoutSession.UserId == userId
                && s.SessionExercise.WorkoutSession.CompletedAt != null);

        if (exerciseIds is not null)
        {
            query = query.Where(s => exerciseIds.Contains(s.SessionExercise.ExerciseId));
        }

        if (before is not null)
        {
            query = query.Where(s => s.SessionExercise.WorkoutSession.CompletedAt < before);
        }

        return query
            .Select(s => new SetRow(
                s.SessionExercise.WorkoutSessionId,
                s.SessionExercise.WorkoutSession.CompletedAt!.Value,
                s.SessionExercise.ExerciseId,
                s.Reps,
                s.WeightKg))
            .ToListAsync();
    }

    private Task<List<SetRow>> LoadSetsOfSessionAsync(Guid sessionId) =>
        context.SessionSets
            .AsNoTracking()
            .Where(s => s.SessionExercise.WorkoutSessionId == sessionId)
            .Select(s => new SetRow(
                s.SessionExercise.WorkoutSessionId,
                s.SessionExercise.WorkoutSession.CompletedAt!.Value,
                s.SessionExercise.ExerciseId,
                s.Reps,
                s.WeightKg))
            .ToListAsync();

    private record ExerciseInfo(string Id, string Name, string GifUrl, string BodyPart);

    private async Task<Dictionary<string, ExerciseInfo>> LoadExerciseInfoAsync(IReadOnlyCollection<string> ids) =>
        await context.Exercises
            .AsNoTracking()
            .Where(e => ids.Contains(e.Id))
            .Select(e => new ExerciseInfo(e.Id, e.Name, e.GifUrl, e.BodyPart))
            .ToDictionaryAsync(e => e.Id);

    private static ExerciseRecordsDto ToRecords(ExerciseInfo exercise, IReadOnlyCollection<SetRow> sets) => new()
    {
        ExerciseId = exercise.Id,
        Name = exercise.Name,
        GifUrl = exercise.GifUrl,
        BodyPart = exercise.BodyPart,
        LastPerformedAt = sets.Max(s => s.CompletedAt),
        SessionCount = sets.Select(s => s.SessionId).Distinct().Count(),
        HeaviestWeight = RecordMath.HeaviestWeight(sets),
        BestEstimated1Rm = RecordMath.BestEstimated1Rm(sets),
        MostReps = RecordMath.MostReps(sets)!, // never null: there is at least one set
        BestSetVolume = RecordMath.BestSetVolume(sets)
    };
}
