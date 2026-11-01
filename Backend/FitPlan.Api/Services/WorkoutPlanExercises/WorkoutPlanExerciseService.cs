

using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.WorkoutPlanExercises;
using FitPlan.Api.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.WorkoutPlanExercises;

public class WorkoutPlanExerciseService(FitPlanDbContext context) : IWorkoutPlanExerciseService
{
    public async Task<Result<WorkoutPlanExerciseResponseDto>> AddExerciseToPlanAsync(Guid userId, Guid planId, AddWorkoutPlanExerciseDto dto)
    {
        var planExists = await context.WorkoutPlans
        .AnyAsync(p => p.Id == planId && p.UserId == userId);

        if (!planExists)
        {
            return Result<WorkoutPlanExerciseResponseDto>.Failure(
                "Workout plan not found.",
                ErrorCodes.WorkoutPlanNotFound);
        }


        var exercise = await context.Exercises
        .AsNoTracking()
        .FirstOrDefaultAsync(e => e.Id == dto.ExerciseId);


        if (exercise is null)
        {
            return Result<WorkoutPlanExerciseResponseDto>.Failure(
                "Exercise not found.",
                 ErrorCodes.ExerciseNotFound);

        }




        var exerciseAlreadyExists = await context.WorkoutPlanExercises
         .AnyAsync(x =>
          x.WorkoutPlanId == planId &&
          x.ExerciseId == dto.ExerciseId);

        if (exerciseAlreadyExists)
        {
            return Result<WorkoutPlanExerciseResponseDto>.Failure(
                "Exercise already exists in this workout plan.",
                ErrorCodes.ExerciseAlreadyExists
            );
        }

        var newWorkoutPlanExercises = new WorkoutPlanExercise
        {
            Id = Guid.NewGuid(),
            WorkoutPlanId = planId,
            ExerciseId = dto.ExerciseId,
            Sets = dto.Sets,
            Reps = dto.Reps,
            Order = dto.Order
        };

        await context.WorkoutPlanExercises.AddAsync(newWorkoutPlanExercises);
        //if some user click add 2 times maybe save it 2 time so i add condition to database
        // Handle duplicate insert attempts caused by concurrent requests.
        try
        {
            await context.SaveChangesAsync();
        }
        catch (DbUpdateException ex) when (
           ex.InnerException is SqlException sqlException &&
            (sqlException.Number == 2601 || sqlException.Number == 2627))
        {
            return Result<WorkoutPlanExerciseResponseDto>.Failure(
                "Exercise already exists in this workout plan.",
                ErrorCodes.ExerciseAlreadyExists);
        }

        var response = new WorkoutPlanExerciseResponseDto
        {
            Id = newWorkoutPlanExercises.Id,
            ExerciseId = dto.ExerciseId,
            Name = exercise.Name,
            GifUrl = exercise.GifUrl,
            Instructions = exercise.Instructions,
            BodyPart = exercise.BodyPart,
            Sets = dto.Sets,
            Reps = dto.Reps,
            Order = dto.Order
        };


        return Result<WorkoutPlanExerciseResponseDto>.Success(response);
    }


    public async Task<Result<WorkoutPlanExerciseResponseDto[]>> GetPlanExercisesAsync(Guid userId, Guid planId)
    {
        var planExists = await context.WorkoutPlans
        .AnyAsync(p => p.Id == planId && p.UserId == userId);

        if (!planExists)
        {
            return Result<WorkoutPlanExerciseResponseDto[]>.Failure(
                "Workout plan not found.",
                ErrorCodes.WorkoutPlanNotFound);
        }

        var bringWorkoutPlanExercise = await context.WorkoutPlanExercises
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

        }).ToArrayAsync();


   
        return Result<WorkoutPlanExerciseResponseDto[]>.Success(bringWorkoutPlanExercise);


    }


 public Task<Result<WorkoutPlanExerciseResponseDto>> UpdatePlanExerciseAsync(Guid userId, Guid planId, Guid id, UpdateWorkoutPlanExerciseDto UpdateWorkoutPlanExercise)
    {
        throw new NotImplementedException();
    }

    public Task<Result<bool>> RemoveExerciseFromPlanAsync(Guid userId, Guid planId, Guid id)
    {
        throw new NotImplementedException();
    }

   
}