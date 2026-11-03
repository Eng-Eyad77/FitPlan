
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Services.CardioEntries;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[Authorize]
[Route("api/sessions/{sessionId:guid}/cardio")]
public class CardioEntriesController(ICardioEntryService cardioEntryService) : ApiControllerBase
{
    [HttpPost]
    public async Task<IActionResult> AddCardio(Guid sessionId, [FromBody] CardioEntryRequestDto cardioEntryRequestDto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await cardioEntryService.AddCardioAsync(userId, sessionId, cardioEntryRequestDto);

        if (!result.IsSuccess)
        {
            return Problem(result.Error);
        }

        return StatusCode(StatusCodes.Status201Created, result.Data);
    }


    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateCardio(Guid sessionId, Guid id, [FromBody] CardioEntryRequestDto cardioEntryRequestDto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await cardioEntryService.UpdateCardioAsync(userId, sessionId, id, cardioEntryRequestDto);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }


    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteCardio(Guid sessionId, Guid id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await cardioEntryService.DeleteCardioAsync(userId, sessionId, id);

        return result.IsSuccess ? NoContent() : Problem(result.Error);
    }
}
