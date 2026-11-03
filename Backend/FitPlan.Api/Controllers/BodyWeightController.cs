
using FitPlan.Api.DTOs.BodyWeight;
using FitPlan.Api.Services.BodyWeight;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[Authorize]
[Route("api/body-weight")]
public class BodyWeightController(IBodyWeightService bodyWeightService) : ApiControllerBase
{
    [HttpPost]
    public async Task<IActionResult> AddBodyWeight([FromBody] AddBodyWeightDto addBodyWeightDto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await bodyWeightService.AddEntryAsync(userId, addBodyWeightDto);

        if (!result.IsSuccess)
        {
            return Problem(result.Error);
        }

        return StatusCode(StatusCodes.Status201Created, result.Data);
    }


    [HttpGet]
    public async Task<IActionResult> GetBodyWeightHistory()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        return Ok(await bodyWeightService.GetHistoryAsync(userId));
    }


    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteBodyWeight(Guid id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await bodyWeightService.DeleteEntryAsync(userId, id);

        return result.IsSuccess ? NoContent() : Problem(result.Error);
    }
}
