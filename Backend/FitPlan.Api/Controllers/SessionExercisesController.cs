
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Services.SessionExercises;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[Authorize]
[Route("api/sessions/{sessionId:guid}/exercises")]
public class SessionExercisesController(ISessionExerciseService sessionExerciseService) : ApiControllerBase
{
    [HttpPost]
    public async Task<IActionResult> AddExercise(Guid sessionId, [FromBody] AddSessionExerciseDto addSessionExerciseDto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await sessionExerciseService.AddExerciseAsync(userId, sessionId, addSessionExerciseDto);

        if (!result.IsSuccess)
        {
            return Problem(result.Error);
        }

        return StatusCode(StatusCodes.Status201Created, result.Data);
    }


    [HttpDelete("{sessionExerciseId:guid}")]
    public async Task<IActionResult> RemoveExercise(Guid sessionId, Guid sessionExerciseId)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await sessionExerciseService.RemoveExerciseAsync(userId, sessionId, sessionExerciseId);

        return result.IsSuccess ? NoContent() : Problem(result.Error);
    }


    [HttpPost("{sessionExerciseId:guid}/sets")]
    public async Task<IActionResult> AddSet(Guid sessionId, Guid sessionExerciseId, [FromBody] SessionSetRequestDto sessionSetRequestDto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await sessionExerciseService.AddSetAsync(userId, sessionId, sessionExerciseId, sessionSetRequestDto);

        if (!result.IsSuccess)
        {
            return Problem(result.Error);
        }

        return StatusCode(StatusCodes.Status201Created, result.Data);
    }


    [HttpPut("{sessionExerciseId:guid}/sets/{setId:guid}")]
    public async Task<IActionResult> UpdateSet(Guid sessionId, Guid sessionExerciseId, Guid setId, [FromBody] SessionSetRequestDto sessionSetRequestDto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await sessionExerciseService.UpdateSetAsync(userId, sessionId, sessionExerciseId, setId, sessionSetRequestDto);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    [HttpDelete("{sessionExerciseId:guid}/sets/{setId:guid}")]
    public async Task<IActionResult> DeleteSet(Guid sessionId, Guid sessionExerciseId, Guid setId)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await sessionExerciseService.DeleteSetAsync(userId, sessionId, sessionExerciseId, setId);

        return result.IsSuccess ? NoContent() : Problem(result.Error);
    }
}
