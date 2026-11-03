
using System.ComponentModel.DataAnnotations;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Services.WorkoutSessions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[Authorize]
[Route("api/sessions")]
public class WorkoutSessionsController(IWorkoutSessionService workoutSessionService) : ApiControllerBase
{
    [HttpPost]
    public async Task<IActionResult> StartSession([FromBody] StartWorkoutSessionDto startWorkoutSessionDto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutSessionService.StartSessionAsync(userId, startWorkoutSessionDto);

        if (!result.IsSuccess)
        {
            return Problem(result.Error);
        }

        return CreatedAtAction
        (
            nameof(GetSessionById),
            new { id = result.Data.Id },
            result.Data
        );
    }


    // the app calls this when it opens, to resume a session that is still in progress
    [HttpGet("active")]
    public async Task<IActionResult> GetActiveSession()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutSessionService.GetActiveSessionAsync(userId);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetSessionById(Guid id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutSessionService.GetSessionByIdAsync(userId, id);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    // history: completed sessions, newest first
    [HttpGet]
    public async Task<IActionResult> GetHistory
    (
        [Range(1, int.MaxValue)] int page = 1,
        [Range(1, 100)] int pageSize = 20
    )
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        return Ok(await workoutSessionService.GetHistoryAsync(userId, page, pageSize));
    }


    [HttpPost("{id:guid}/complete")]
    public async Task<IActionResult> CompleteSession(Guid id, [FromBody] CompleteWorkoutSessionDto completeWorkoutSessionDto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutSessionService.CompleteSessionAsync(userId, id, completeWorkoutSessionDto);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    // cancel a session in progress, or delete a completed one
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteSession(Guid id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await workoutSessionService.DeleteSessionAsync(userId, id);

        return result.IsSuccess ? NoContent() : Problem(result.Error);
    }
}
