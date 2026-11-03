
using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.WorkoutPlans;

namespace FitPlan.Api.Services.WorkoutPlans;

public interface IWorkoutPlanService
{
    Task<Result<WorkoutPlanResponseDto>> CreateWorkoutPlanAsync(CreateWorkoutPlanDto createPlan, Guid userId);

    Task<WorkoutPlanResponseDto[]> GetAllMyWorkoutPlansAsync(Guid userId);

    Task<Result<WorkoutPlanResponseDto>> GetWorkoutPlanByIdAsync(Guid userId, Guid id);

    Task<Result<WorkoutPlanResponseDto>> UpdateWorkoutPlanAsync(Guid userId, Guid id, UpdateWorkoutPlanDto newPlanDetails);

    Task<Result<bool>> DeleteWorkoutPlanAsync(Guid id, Guid userId);

}
