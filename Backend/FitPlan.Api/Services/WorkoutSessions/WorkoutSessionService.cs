
using System.Linq.Expressions;
using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Common;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Stats;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.WorkoutSessions;

public class WorkoutSessionService(FitPlanDbContext context, IVolumeService volume) : IWorkoutSessionService
{
    private const string QuickWorkoutName = "Quick Workout";


    public async Task<Result<WorkoutSessionResponseDto>> StartSessionAsync(Guid userId, StartWorkoutSessionDto dto)
    {
        var hasActiveSession = await context.WorkoutSessions
            .AnyAsync(s => s.UserId == userId && s.CompletedAt == null);

        if (hasActiveSession)
        {
            return Result<WorkoutSessionResponseDto>.Failure(Errors.ActiveSessionExists);
        }

        var session = new WorkoutSession
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Name = QuickWorkoutName,
            StartedAt = DateTime.UtcNow
        };

        // starting from a plan: copy its exercises as the starting point of the session
        if (dto.WorkoutPlanId is Guid planId)
        {
            var plan = await context.WorkoutPlans
                .AsNoTracking()
                .Include(p => p.Exercises)
                .FirstOrDefaultAsync(p => p.Id == planId && p.UserId == userId);

            if (plan is null)
            {
                return Result<WorkoutSessionResponseDto>.Failure(Errors.WorkoutPlanNotFound);
            }

            session.WorkoutPlanId = plan.Id;
            session.Name = plan.Name;
            session.Exercises = plan.Exercises
                .OrderBy(e => e.Order)
                .Select((planExercise, index) => new SessionExercise
                {
                    Id = Guid.NewGuid(),
                    ExerciseId = planExercise.ExerciseId,
                    Order = index + 1, // 1, 2, 3... even if the plan orders have gaps
                    TargetSets = planExercise.Sets,
                    TargetReps = planExercise.Reps,
                    RestSeconds = planExercise.RestSeconds,
                    Note = planExercise.Note
                })
                .ToList();
        }

        context.WorkoutSessions.Add(session);

        // the filtered unique index stops a second active session from two requests at the same moment
        try
        {
            await context.SaveChangesAsync();
        }
        catch (DbUpdateException ex) when (ex.IsUniqueConstraintViolation())
        {
            return Result<WorkoutSessionResponseDto>.Failure(Errors.ActiveSessionExists);
        }

        var response = await LoadSessionDtoAsync(userId, s => s.Id == session.Id);

        return Result<WorkoutSessionResponseDto>.Success(response!);
    }


    public async Task<Result<WorkoutSessionResponseDto>> GetActiveSessionAsync(Guid userId)
    {
        var response = await LoadSessionDtoAsync(userId, s => s.CompletedAt == null);

        return response is null
            ? Result<WorkoutSessionResponseDto>.Failure(Errors.NoActiveSession)
            : Result<WorkoutSessionResponseDto>.Success(response);
    }


    public async Task<Result<WorkoutSessionResponseDto>> GetSessionByIdAsync(Guid userId, Guid id)
    {
        var response = await LoadSessionDtoAsync(userId, s => s.Id == id);

        return response is null
            ? Result<WorkoutSessionResponseDto>.Failure(Errors.WorkoutSessionNotFound)
            : Result<WorkoutSessionResponseDto>.Success(response);
    }


    // completed sessions only, newest first
    public async Task<PagedResponseDto<WorkoutSessionSummaryDto>> GetHistoryAsync(Guid userId, int page, int pageSize, DateTime? since = null)
    {
        var query = context.WorkoutSessions
            .AsNoTracking()
            .Where(s => s.UserId == userId && s.CompletedAt != null);
        if (since is { } from)
        {
            var utc = from.Kind == DateTimeKind.Local ? from.ToUniversalTime() : DateTime.SpecifyKind(from, DateTimeKind.Utc);
            query = query.Where(s => s.CompletedAt >= utc);
        }

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(s => s.CompletedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(WorkoutSessionMappings.ToSummaryDto)
            .ToArrayAsync();

        return new PagedResponseDto<WorkoutSessionSummaryDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling((double)totalCount / pageSize)
        };
    }


    public async Task<Result<WorkoutSessionSummaryDto>> CompleteSessionAsync(Guid userId, Guid id, CompleteWorkoutSessionDto dto)
    {
        var session = await context.WorkoutSessions
            .Include(s => s.Exercises)
                .ThenInclude(e => e.Sets)
            .Include(s => s.CardioEntries)
            .AsSplitQuery()
            .FirstOrDefaultAsync(s => s.Id == id && s.UserId == userId);

        if (session is null)
        {
            return Result<WorkoutSessionSummaryDto>.Failure(Errors.WorkoutSessionNotFound);
        }

        if (session.CompletedAt is not null)
        {
            return Result<WorkoutSessionSummaryDto>.Failure(Errors.SessionNotActive);
        }

        await CopyNotesToPlanAsync(session);

        // exercises copied from the plan but skipped by the user (no sets logged)
        var skippedExercises = session.Exercises.Where(e => e.Sets.Count == 0).ToList();

        if (skippedExercises.Count == session.Exercises.Count && session.CardioEntries.Count == 0)
        {
            return Result<WorkoutSessionSummaryDto>.Failure(Errors.EmptySession);
        }

        // the history only keeps what was actually done
        context.SessionExercises.RemoveRange(skippedExercises);

        session.CompletedAt = DateTime.UtcNow;
        session.Notes = dto.Notes;

        await context.SaveChangesAsync();

        var summary = await context.WorkoutSessions
            .AsNoTracking()
            .Where(s => s.Id == id)
            .Select(WorkoutSessionMappings.ToSummaryDto)
            .FirstAsync();

        summary.NewMilestones = await volume.SyncAsync(userId, id);

        return Result<WorkoutSessionSummaryDto>.Success(summary);
    }


    // cancels a session in progress, or deletes a completed one from the history
    public async Task<Result<bool>> DeleteSessionAsync(Guid userId, Guid id)
    {
        var session = await context.WorkoutSessions
            .FirstOrDefaultAsync(s => s.Id == id && s.UserId == userId);

        if (session is null)
        {
            return Result<bool>.Failure(Errors.WorkoutSessionNotFound);
        }

        // exercises, sets and cardio are deleted by the cascade
        context.WorkoutSessions.Remove(session);
        await context.SaveChangesAsync();

        return Result<bool>.Success(true);
    }


    // Loads the full session of the user that matches the filter, with "last performance" while in progress.
    private async Task<WorkoutSessionResponseDto?> LoadSessionDtoAsync(
        Guid userId,
        Expression<Func<WorkoutSession, bool>> filter)
    {
        var session = await context.WorkoutSessions
            .AsNoTracking()
            .Where(s => s.UserId == userId)
            .Where(filter)
            .Include(s => s.Exercises)
                .ThenInclude(e => e.Exercise)
            .Include(s => s.Exercises)
                .ThenInclude(e => e.Sets)
            .Include(s => s.CardioEntries)
            .AsSplitQuery() // separate queries instead of one big JOIN that repeats rows
            .FirstOrDefaultAsync();

        if (session is null)
        {
            return null;
        }

        var history = session.CompletedAt is null
            ? await LastPerformanceQuery.GetAsync(
                context,
                userId,
                session.Exercises.Select(e => e.ExerciseId).ToList())
            : [];

        return WorkoutSessionMappings.ToSessionDto(session, history);
    }

    // A note changed during the workout goes back to the plan's exercise, matched by exercise in plan
    // order. Only exercises that came from the plan (they have targets); ones added in the session don't.
    private async Task CopyNotesToPlanAsync(WorkoutSession session)
    {
        if (session.WorkoutPlanId is not Guid planId)
        {
            return;
        }

        var planExercises = await context.WorkoutPlanExercises
            .Where(p => p.WorkoutPlanId == planId)
            .OrderBy(p => p.Order)
            .ToListAsync();

        foreach (var exercise in session.Exercises.Where(e => e.TargetSets != null).OrderBy(e => e.Order))
        {
            var planExercise = planExercises.FirstOrDefault(p => p.ExerciseId == exercise.ExerciseId);
            if (planExercise is null)
            {
                continue;
            }

            planExercises.Remove(planExercise);
            planExercise.Note = exercise.Note;
        }
    }
}
