
using System.Security.Claims;
using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.WorkoutPlanExercises;
using FitPlan.Api.Services.WorkoutPlanExercises;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/workout-plans/{planId:guid}/exercises")]

public class WorkoutPlanExercisesController(IWorkoutPlanExerciseService workoutPlanExerciseService) : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> CreateWorkoutPlanExercise(Guid planId, [FromBody] AddWorkoutPlanExerciseDto addWorkoutPlanExerciseDto)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanExerciseService.AddExerciseToPlanAsync
        (
         userId,
          planId,
          addWorkoutPlanExerciseDto
         );

        if (!result.IsSuccess)
        {
            if (result.ErrorCode == ErrorCodes.WorkoutPlanNotFound)
            {
                return NotFound(result.Error);
            }

            if (result.ErrorCode == ErrorCodes.ExerciseNotFound)
            {
                return NotFound(result.Error);
            }

            if (result.ErrorCode == ErrorCodes.ExerciseAlreadyExists)
            {
                return Conflict(result.Error);
            }

            return BadRequest(result.Error);
        }



        return StatusCode(StatusCodes.Status201Created, result.Data);

    }

    [HttpGet]
    public async Task<IActionResult> GetWorkoutPlanExercises(Guid planId)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanExerciseService.GetPlanExercisesAsync
        (
         userId,
          planId
         );

         if(!result.IsSuccess)
        {
              if (result.ErrorCode == ErrorCodes.WorkoutPlanNotFound)
            {
                return NotFound(result.Error);
            }
            return BadRequest(result.Error);
        }

        return Ok(result.Data);
    }


    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateWorkoutPlanExercise
    (
        Guid planId,
        Guid id,
       [FromBody] UpdateWorkoutPlanExerciseDto updateWorkoutPlanExercise
    )
    {
         var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanExerciseService.UpdatePlanExerciseAsync
        (
         userId,
          planId,
          id,
          updateWorkoutPlanExercise
         );

            if(!result.IsSuccess)
        {
             if (result.ErrorCode == ErrorCodes.WorkoutPlanNotFound)
            {
                return NotFound(result.Error);
            }

            if(result.ErrorCode == ErrorCodes.WorkoutPlanExerciseNotFound)
            {
                return NotFound(result.Error);
            }

            return BadRequest(result.Error);
        }


        return Ok(result.Data);

    }

    


    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> RemoveWorkoutPlanExercise
    (
        Guid id,
        Guid planId
    )
    {
         var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutPlanExerciseService.RemoveExerciseFromPlanAsync
        (
         userId,
          planId,
          id
         );

          if(!result.IsSuccess)
        {
             if (result.ErrorCode == ErrorCodes.WorkoutPlanNotFound)
            {
                return NotFound(result.Error);
            }

            if(result.ErrorCode == ErrorCodes.WorkoutPlanExerciseNotFound)
            {
                return NotFound(result.Error);
            }

            return BadRequest(result.Error);
        }


        return NoContent();
        
            
    }
    
}
