

using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.WorkoutPlanExercises;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.WorkoutPlanExercises;

public class WorkoutPlanExerciseService(FitPlanDbContext context) : IWorkoutPlanExerciseService
{
    public async Task<Result<WorkoutPlanExerciseResponseDto>> AddExerciseToPlanAsync(Guid userId, Guid planId, AddWorkoutPlanExerciseDto dto)
    {
        var plan = await FindUserPlanAsync(userId, planId);

        if (plan is null)
        {
            return Result<WorkoutPlanExerciseResponseDto>.Failure(Errors.WorkoutPlanNotFound);
        }

        var exercise = await context.Exercises
            .AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == dto.ExerciseId);

        if (exercise is null)
        {
            return Result<WorkoutPlanExerciseResponseDto>.Failure(Errors.ExerciseNotFound);
        }

        var exerciseAlreadyExists = await context.WorkoutPlanExercises
            .AnyAsync(x => x.WorkoutPlanId == planId && x.ExerciseId == dto.ExerciseId);

        if (exerciseAlreadyExists)
        {
            return Result<WorkoutPlanExerciseResponseDto>.Failure(Errors.ExerciseAlreadyExists);
        }

        var newWorkoutPlanExercise = new WorkoutPlanExercise
        {
            Id = Guid.NewGuid(),
            WorkoutPlanId = planId,
            ExerciseId = dto.ExerciseId,
            Sets = dto.Sets,
            Reps = dto.Reps,
            Order = dto.Order
        };

        context.WorkoutPlanExercises.Add(newWorkoutPlanExercise);

        // changing the plan's exercises is a change to the plan itself
        plan.UpdatedAt = DateTime.UtcNow;

        //if some user click add 2 times maybe save it 2 time so i add condition to database
        // Handle duplicate insert attempts caused by concurrent requests.
        try
        {
            await context.SaveChangesAsync();
        }
        catch (DbUpdateException ex) when (ex.IsUniqueConstraintViolation())
        {
            return Result<WorkoutPlanExerciseResponseDto>.Failure(Errors.ExerciseAlreadyExists);
        }

        var response = new WorkoutPlanExerciseResponseDto
        {
            Id = newWorkoutPlanExercise.Id,
            ExerciseId = exercise.Id,
            Name = exercise.Name,
            GifUrl = exercise.GifUrl,
            Instructions = exercise.Instructions,
            BodyPart = exercise.BodyPart,
            Sets = newWorkoutPlanExercise.Sets,
            Reps = newWorkoutPlanExercise.Reps,
            Order = newWorkoutPlanExercise.Order
        };

        return Result<WorkoutPlanExerciseResponseDto>.Success(response);
    }


    public async Task<Result<WorkoutPlanExerciseResponseDto[]>> GetPlanExercisesAsync(Guid userId, Guid planId)
    {
        var planExists = await context.WorkoutPlans
            .AnyAsync(p => p.Id == planId && p.UserId == userId);

        if (!planExists)
        {
            return Result<WorkoutPlanExerciseResponseDto[]>.Failure(Errors.WorkoutPlanNotFound);
        }

        var planExercises = await context.WorkoutPlanExercises
            .AsNoTracking()
            .Where(p => p.WorkoutPlanId == planId)
            .OrderBy(item => item.Order)
            .ThenBy(item => item.Id)
            .Select(item => new WorkoutPlanExerciseResponseDto
            {
                Id = item.Id,
                ExerciseId = item.ExerciseId,
                Name = item.Exercise.Name,
                GifUrl = item.Exercise.GifUrl,
                BodyPart = item.Exercise.BodyPart,
                Instructions = item.Exercise.Instructions,
                Sets = item.Sets,
                Reps = item.Reps,
                Order = item.Order
            })
            .ToArrayAsync();

        return Result<WorkoutPlanExerciseResponseDto[]>.Success(planExercises);
    }


    public async Task<Result<WorkoutPlanExerciseResponseDto>> UpdatePlanExerciseAsync(Guid userId, Guid planId, Guid id, UpdateWorkoutPlanExerciseDto dto)
    {
        var plan = await FindUserPlanAsync(userId, planId);

        if (plan is null)
        {
            return Result<WorkoutPlanExerciseResponseDto>.Failure(Errors.WorkoutPlanNotFound);
        }

        var planExercise = await context.WorkoutPlanExercises
            .Include(p => p.Exercise)
            .FirstOrDefaultAsync(p => p.WorkoutPlanId == planId && p.Id == id);

        if (planExercise is null)
        {
            return Result<WorkoutPlanExerciseResponseDto>.Failure(Errors.WorkoutPlanExerciseNotFound);
        }

        planExercise.Sets = dto.Sets;
        planExercise.Reps = dto.Reps;
        planExercise.Order = dto.Order;
        plan.UpdatedAt = DateTime.UtcNow;

        await context.SaveChangesAsync();

        var response = new WorkoutPlanExerciseResponseDto
        {
            Id = planExercise.Id,
            ExerciseId = planExercise.ExerciseId,
            Name = planExercise.Exercise.Name,
            GifUrl = planExercise.Exercise.GifUrl,
            Instructions = planExercise.Exercise.Instructions,
            BodyPart = planExercise.Exercise.BodyPart,
            Sets = planExercise.Sets,
            Reps = planExercise.Reps,
            Order = planExercise.Order
        };

        return Result<WorkoutPlanExerciseResponseDto>.Success(response);
    }

    public async Task<Result<bool>> RemoveExerciseFromPlanAsync(Guid userId, Guid planId, Guid id)
    {
        var plan = await FindUserPlanAsync(userId, planId);

        if (plan is null)
        {
            return Result<bool>.Failure(Errors.WorkoutPlanNotFound);
        }

        var planExercise = await context.WorkoutPlanExercises
            .FirstOrDefaultAsync(p => p.WorkoutPlanId == planId && p.Id == id);

        if (planExercise is null)
        {
            return Result<bool>.Failure(Errors.WorkoutPlanExerciseNotFound);
        }

        context.WorkoutPlanExercises.Remove(planExercise);
        plan.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync();

        return Result<bool>.Success(true);
    }


    // Ownership check: the plan must exist AND belong to the authenticated user.
    // Returned as a tracked entity so the caller can update its UpdatedAt.
    private Task<WorkoutPlan?> FindUserPlanAsync(Guid userId, Guid planId) =>
        context.WorkoutPlans.FirstOrDefaultAsync(p => p.Id == planId && p.UserId == userId);
}
