
using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Models;
using FitPlan.Api.Services.WorkoutSessions;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.SessionExercises;

// Every method first calls CheckActiveSessionAsync (ownership + in progress),
// so after it, filtering by sessionId alone is safe.
public class SessionExerciseService(FitPlanDbContext context) : ISessionExerciseService
{
    private const int MaxSetsPerExercise = 10;


    public async Task<Result<SessionExerciseResponseDto>> AddExerciseAsync(Guid userId, Guid sessionId, AddSessionExerciseDto dto)
    {
        if (await context.CheckActiveSessionAsync(userId, sessionId) is { } error)
        {
            return Result<SessionExerciseResponseDto>.Failure(error);
        }

        var exercise = await context.Exercises
            .AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == dto.ExerciseId);

        if (exercise is null)
        {
            return Result<SessionExerciseResponseDto>.Failure(Errors.ExerciseNotFound);
        }

        var alreadyInSession = await context.SessionExercises
            .AnyAsync(e => e.WorkoutSessionId == sessionId && e.ExerciseId == dto.ExerciseId);

        if (alreadyInSession)
        {
            return Result<SessionExerciseResponseDto>.Failure(Errors.ExerciseAlreadyInSession);
        }

        // added at the end of the session
        var lastOrder = await context.SessionExercises
            .Where(e => e.WorkoutSessionId == sessionId)
            .MaxAsync(e => (int?)e.Order) ?? 0;

        var sessionExercise = new SessionExercise
        {
            Id = Guid.NewGuid(),
            WorkoutSessionId = sessionId,
            ExerciseId = exercise.Id,
            Order = lastOrder + 1
        };

        context.SessionExercises.Add(sessionExercise);

        try
        {
            await context.SaveChangesAsync();
        }
        catch (DbUpdateException ex) when (ex.IsUniqueConstraintViolation())
        {
            return Result<SessionExerciseResponseDto>.Failure(Errors.ExerciseAlreadyInSession);
        }

        sessionExercise.Exercise = exercise;

        var history = await LastPerformanceQuery.GetAsync(context, userId, [exercise.Id]);

        return Result<SessionExerciseResponseDto>.Success(
            WorkoutSessionMappings.ToExerciseDto(sessionExercise, history.GetValueOrDefault(exercise.Id)));
    }


    public async Task<Result<bool>> RemoveExerciseAsync(Guid userId, Guid sessionId, Guid sessionExerciseId)
    {
        if (await context.CheckActiveSessionAsync(userId, sessionId) is { } error)
        {
            return Result<bool>.Failure(error);
        }

        var sessionExercise = await context.SessionExercises
            .FirstOrDefaultAsync(e => e.Id == sessionExerciseId && e.WorkoutSessionId == sessionId);

        if (sessionExercise is null)
        {
            return Result<bool>.Failure(Errors.SessionExerciseNotFound);
        }

        // its sets are deleted by the cascade
        context.SessionExercises.Remove(sessionExercise);
        await context.SaveChangesAsync();

        return Result<bool>.Success(true);
    }


    public async Task<Result<SessionSetResponseDto>> AddSetAsync(Guid userId, Guid sessionId, Guid sessionExerciseId, SessionSetRequestDto dto)
    {
        if (await context.CheckActiveSessionAsync(userId, sessionId) is { } error)
        {
            return Result<SessionSetResponseDto>.Failure(error);
        }

        var sessionExercise = await context.SessionExercises
            .Where(e => e.Id == sessionExerciseId && e.WorkoutSessionId == sessionId)
            .Select(e => new
            {
                SetCount = e.Sets.Count,
                LastSetNumber = e.Sets.Max(s => (int?)s.SetNumber)
            })
            .FirstOrDefaultAsync();

        if (sessionExercise is null)
        {
            return Result<SessionSetResponseDto>.Failure(Errors.SessionExerciseNotFound);
        }

        if (sessionExercise.SetCount >= MaxSetsPerExercise)
        {
            return Result<SessionSetResponseDto>.Failure(Errors.SetLimitReached);
        }

        var set = new SessionSet
        {
            Id = Guid.NewGuid(),
            SessionExerciseId = sessionExerciseId,
            SetNumber = (sessionExercise.LastSetNumber ?? 0) + 1,
            Reps = dto.Reps,
            WeightKg = dto.WeightKg
        };

        context.SessionSets.Add(set);
        await context.SaveChangesAsync();

        return Result<SessionSetResponseDto>.Success(WorkoutSessionMappings.ToSetDto(set));
    }


    public async Task<Result<SessionSetResponseDto>> UpdateSetAsync(Guid userId, Guid sessionId, Guid sessionExerciseId, Guid setId, SessionSetRequestDto dto)
    {
        if (await context.CheckActiveSessionAsync(userId, sessionId) is { } error)
        {
            return Result<SessionSetResponseDto>.Failure(error);
        }

        var set = await FindSetAsync(sessionId, sessionExerciseId, setId);

        if (set is null)
        {
            return Result<SessionSetResponseDto>.Failure(Errors.SessionSetNotFound);
        }

        set.Reps = dto.Reps;
        set.WeightKg = dto.WeightKg;
        await context.SaveChangesAsync();

        return Result<SessionSetResponseDto>.Success(WorkoutSessionMappings.ToSetDto(set));
    }


    public async Task<Result<bool>> DeleteSetAsync(Guid userId, Guid sessionId, Guid sessionExerciseId, Guid setId)
    {
        if (await context.CheckActiveSessionAsync(userId, sessionId) is { } error)
        {
            return Result<bool>.Failure(error);
        }

        var set = await FindSetAsync(sessionId, sessionExerciseId, setId);

        if (set is null)
        {
            return Result<bool>.Failure(Errors.SessionSetNotFound);
        }

        context.SessionSets.Remove(set);

        // keep the numbers without gaps: deleting set 2 of 3 makes set 3 become set 2
        var laterSets = await context.SessionSets
            .Where(s => s.SessionExerciseId == sessionExerciseId && s.SetNumber > set.SetNumber)
            .ToListAsync();

        foreach (var laterSet in laterSets)
        {
            laterSet.SetNumber--;
        }

        await context.SaveChangesAsync();

        return Result<bool>.Success(true);
    }


    private Task<SessionSet?> FindSetAsync(Guid sessionId, Guid sessionExerciseId, Guid setId) =>
        context.SessionSets.FirstOrDefaultAsync(s =>
            s.Id == setId &&
            s.SessionExerciseId == sessionExerciseId &&
            s.SessionExercise.WorkoutSessionId == sessionId);
}
