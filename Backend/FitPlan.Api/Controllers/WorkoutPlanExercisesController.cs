
using FitPlan.Api.DTOs.WorkoutPlanExercises;
using FitPlan.Api.Services.WorkoutPlanExercises;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[Authorize]
[Route("api/workout-plans/{planId:guid}/exercises")]
public class WorkoutPlanExercisesController(IWorkoutPlanExerciseService workoutPlanExerciseService) : ApiControllerBase
{
    [HttpPost]
    public async Task<IActionResult> CreateWorkoutPlanExercise(Guid planId, [FromBody] AddWorkoutPlanExerciseDto addWorkoutPlanExerciseDto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanExerciseService.AddExerciseToPlanAsync(userId, planId, addWorkoutPlanExerciseDto);

        if (!result.IsSuccess)
        {
            return Problem(result.Error);
        }

        return StatusCode(StatusCodes.Status201Created, result.Data);
    }


    [HttpGet]
    public async Task<IActionResult> GetWorkoutPlanExercises(Guid planId)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanExerciseService.GetPlanExercisesAsync(userId, planId);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateWorkoutPlanExercise
    (
        Guid planId,
        Guid id,
        [FromBody] UpdateWorkoutPlanExerciseDto updateWorkoutPlanExercise
    )
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanExerciseService.UpdatePlanExerciseAsync(userId, planId, id, updateWorkoutPlanExercise);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> RemoveWorkoutPlanExercise(Guid planId, Guid id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanExerciseService.RemoveExerciseFromPlanAsync(userId, planId, id);

        return result.IsSuccess ? NoContent() : Problem(result.Error);
    }
}
