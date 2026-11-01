
using FitPlan.Api.DTOs.WorkoutPlans;

namespace FitPlan.Api.Services.WorkoutPlans;

public interface IWorkoutPlanService
{
    Task<WorkoutPlanResponseDto?> CreateWorkoutPlanAsync(CreateWorkoutPlanDto createPlan, Guid userId);
    
    Task<WorkoutPlanResponseDto[]> GetAllMyWorkoutPlansAsync(Guid userId);

    Task<WorkoutPlanResponseDto?> GetWorkoutPlanByIdAsync( Guid userId, Guid id);

    Task<WorkoutPlanResponseDto?> UpdateWorkoutPlanAsync(Guid userId, Guid id, UpdateWorkoutPlanDto newPlanDetails);
    
    Task<bool> DeleteWorkoutPlanAsync(Guid id, Guid userId);

}
