using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.WorkoutPlans;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.WorkoutPlans;

public class WorkoutPlanService(FitPlanDbContext context) : IWorkoutPlanService
{
    public async Task<Result<WorkoutPlanResponseDto>> CreateWorkoutPlanAsync(CreateWorkoutPlanDto createPlan, Guid userId)
    {
        var userExists = await context.Users.AnyAsync(u => u.Id == userId);

        if (!userExists)
        {
            return Result<WorkoutPlanResponseDto>.Failure(Errors.UserNotFound);
        }

        var newPlan = new WorkoutPlan
        {
            Id = Guid.NewGuid(),
            Name = createPlan.Name,
            Description = createPlan.Description,
            UserId = userId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        context.WorkoutPlans.Add(newPlan);
        await context.SaveChangesAsync();

        return Result<WorkoutPlanResponseDto>.Success(ToResponseDto(newPlan));
    }


    // This one cannot fail: a user with no plans simply gets an empty array.
    public async Task<WorkoutPlanResponseDto[]> GetAllMyWorkoutPlansAsync(Guid userId)
    {
        return await context.WorkoutPlans
            .AsNoTracking()
            .Where(plan => plan.UserId == userId)
            .OrderByDescending(plan => plan.CreatedAt) // newest plan first
            .Select(plan => new WorkoutPlanResponseDto
            {
                Id = plan.Id,
                Name = plan.Name,
                Description = plan.Description,
                CreatedAt = plan.CreatedAt,
                UpdatedAt = plan.UpdatedAt,
                ExerciseCount = plan.Exercises.Count
            })
            .ToArrayAsync();
    }

    public async Task<Result<WorkoutPlanResponseDto>> GetWorkoutPlanByIdAsync(Guid userId, Guid id)
    {
        var specificUserPlan = await context.WorkoutPlans
            .AsNoTracking()
            .FirstOrDefaultAsync(plan => plan.Id == id && plan.UserId == userId);

        if (specificUserPlan is null)
        {
            return Result<WorkoutPlanResponseDto>.Failure(Errors.WorkoutPlanNotFound);
        }

        var exerciseCount = await context.WorkoutPlanExercises.CountAsync(item => item.WorkoutPlanId == id);

        return Result<WorkoutPlanResponseDto>.Success(ToResponseDto(specificUserPlan, exerciseCount));
    }

    public async Task<Result<WorkoutPlanResponseDto>> UpdateWorkoutPlanAsync
    (
        Guid userId,
        Guid id,
        UpdateWorkoutPlanDto newPlanDetails
    )
    {
        var updatePlan = await context.WorkoutPlans
            .FirstOrDefaultAsync(plan => plan.Id == id && plan.UserId == userId);

        if (updatePlan is null)
        {
            return Result<WorkoutPlanResponseDto>.Failure(Errors.WorkoutPlanNotFound);
        }

        updatePlan.Name = newPlanDetails.Name;
        updatePlan.Description = newPlanDetails.Description;
        updatePlan.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync();

        var exerciseCount = await context.WorkoutPlanExercises.CountAsync(item => item.WorkoutPlanId == id);

        return Result<WorkoutPlanResponseDto>.Success(ToResponseDto(updatePlan, exerciseCount));
    }

    public async Task<Result<bool>> DeleteWorkoutPlanAsync(Guid id, Guid userId)
    {
        var planWantToDelete = await context.WorkoutPlans
            .FirstOrDefaultAsync(plan => plan.Id == id && plan.UserId == userId);

        if (planWantToDelete is null)
        {
            return Result<bool>.Failure(Errors.WorkoutPlanNotFound);
        }

        context.WorkoutPlans.Remove(planWantToDelete);
        await context.SaveChangesAsync();

        return Result<bool>.Success(true);
    }


    // a new plan has no exercises yet, so the count defaults to 0
    private static WorkoutPlanResponseDto ToResponseDto(WorkoutPlan plan, int exerciseCount = 0) => new()
    {
        Id = plan.Id,
        Name = plan.Name,
        Description = plan.Description,
        CreatedAt = plan.CreatedAt,
        UpdatedAt = plan.UpdatedAt,
        ExerciseCount = exerciseCount
    };
}
