using FitPlan.Api.Data;
using FitPlan.Api.DTOs.WorkoutPlans;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.WorkoutPlans;

public class WorkoutPlanService(FitPlanDbContext context) : IWorkoutPlanService
{
    public async Task<WorkoutPlanResponseDto?> CreateWorkoutPlanAsync(CreateWorkoutPlanDto createPlan, Guid userId)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
        {
            return null;
        }

        var newPlan = new WorkoutPlan
        {
            Id = Guid.NewGuid(),
            Name = createPlan.Name,
            Description = createPlan.Description,
            UserId = user.Id,
            User = user,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        context.WorkoutPlans.Add(newPlan);
        await context.SaveChangesAsync();

        return new WorkoutPlanResponseDto
        {
            Id = newPlan.Id,
            Name = newPlan.Name,
            Description = newPlan.Description,
            CreatedAt = newPlan.CreatedAt,
            UpdatedAt = newPlan.UpdatedAt
        };
    }

  

    public async Task<WorkoutPlanResponseDto[]> GetAllMyWorkoutPlansAsync(Guid userId)
    {
        var userPlans = context.WorkoutPlans
        .Where(allPlans => allPlans.UserId == userId);

        
       var result = userPlans.Select(plan => new WorkoutPlanResponseDto
        {
            Id = plan.Id,
            Name = plan.Name,
            Description = plan.Description,
            CreatedAt = plan.CreatedAt,
            UpdatedAt = plan.UpdatedAt
        }).ToArrayAsync();


        return await result;

    }

    public async Task<WorkoutPlanResponseDto?> GetWorkoutPlanByIdAsync(Guid userId, Guid id)
    {
        var specificUserPlan = await context.WorkoutPlans
        .FirstOrDefaultAsync(plan => plan.Id == id && plan.UserId == userId);

        if(specificUserPlan is null)
        {
            return null;
        }

        var result = new WorkoutPlanResponseDto
        {
            Id = specificUserPlan.Id,
            Name = specificUserPlan.Name,
            Description = specificUserPlan.Description,
            CreatedAt = specificUserPlan.CreatedAt,
            UpdatedAt = specificUserPlan.UpdatedAt
        };

        return  result;

    }

    public async Task<WorkoutPlanResponseDto?> UpdateWorkoutPlanAsync
    (
        Guid userId, 
        Guid id, 
        UpdateWorkoutPlanDto newPlanDetails
    )
    {
        var updatePlan = await context.WorkoutPlans
        .FirstOrDefaultAsync(updatedPlan => updatedPlan.Id == id && updatedPlan.UserId == userId);

        if(updatePlan is null)
        {
            return null;
        }

        updatePlan.Name = newPlanDetails.Name;
        updatePlan.Description = newPlanDetails.Description;
        updatePlan.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync();
        

        var result = new WorkoutPlanResponseDto
        {
            Id = updatePlan.Id,
            Name = updatePlan.Name,
            Description = updatePlan.Description,
            CreatedAt = updatePlan.CreatedAt,
            UpdatedAt = updatePlan.UpdatedAt
        };

        return  result;
    }

      public async Task<bool> DeleteWorkoutPlanAsync(Guid id, Guid userId)
    {
       var planWantToDelete = await context.WorkoutPlans.FirstOrDefaultAsync
       (
        selectedPlan => selectedPlan.Id == id && selectedPlan.UserId == userId
        );

        if(planWantToDelete is null)
        {
            return false;
        }

        context.WorkoutPlans.Remove(planWantToDelete);
        await context.SaveChangesAsync();

        return true;
    }
}
