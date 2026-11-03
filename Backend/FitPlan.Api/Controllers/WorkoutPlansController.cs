
using FitPlan.Api.DTOs.WorkoutPlans;
using FitPlan.Api.Services.WorkoutPlans;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[Authorize]
[Route("api/workout-plans")]
public class WorkoutPlansController(IWorkoutPlanService workoutPlanService) : ApiControllerBase
{
    [HttpPost]
    public async Task<IActionResult> CreateWorkoutPlan([FromBody] CreateWorkoutPlanDto createWorkoutPlan)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanService.CreateWorkoutPlanAsync(createWorkoutPlan, userId);

        if (!result.IsSuccess)
        {
            return Problem(result.Error);
        }

        return CreatedAtAction
        (
            nameof(GetWorkoutPlanById),
            new { id = result.Data.Id },
            result.Data
        );
    }


    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetWorkoutPlanById(Guid id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanService.GetWorkoutPlanByIdAsync(userId, id);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    [HttpGet]
    public async Task<IActionResult> GetMyWorkoutPlans()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        return Ok(await workoutPlanService.GetAllMyWorkoutPlansAsync(userId));
    }


    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateWorkoutPlan([FromBody] UpdateWorkoutPlanDto updateWorkoutPlan, Guid id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanService.UpdateWorkoutPlanAsync(userId, id, updateWorkoutPlan);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteWorkoutPlan(Guid id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanService.DeleteWorkoutPlanAsync(id, userId);

        return result.IsSuccess ? NoContent() : Problem(result.Error);
    }
}
