using FitPlan.Api.DTOs.Stats;
using FitPlan.Api.Services.Stats;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[Authorize]
[Route("api/stats")]
public class StatsController(IStatsService statsService) : ApiControllerBase
{
    // GET api/stats/overview?weeks=12&utcOffsetMinutes=180&weekStartsOn=Sunday
    [HttpGet("overview")]
    public async Task<IActionResult> GetOverview([FromQuery] StatsOverviewQuery query)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await statsService.GetOverviewAsync(userId, query);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    // personal records of every exercise the user has done
    [HttpGet("records")]
    public async Task<IActionResult> GetRecords()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        return Ok(await statsService.GetRecordsAsync(userId));
    }


    // one exercise over time, for its chart
    [HttpGet("exercises/{exerciseId}")]
    public async Task<IActionResult> GetExerciseProgress(string exerciseId)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await statsService.GetExerciseProgressAsync(userId, exerciseId);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    // a completed workout vs the previous one of the same plan, with the records it beat
    [HttpGet("sessions/{sessionId:guid}/comparison")]
    public async Task<IActionResult> GetSessionComparison(Guid sessionId)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await statsService.GetSessionComparisonAsync(userId, sessionId);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }
}
