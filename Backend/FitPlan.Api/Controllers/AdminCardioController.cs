using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.Extensions;
using FitPlan.Api.Models;
using FitPlan.Api.Services.CardioEntries;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Controllers;

// Phase 12D: the cardio machines and how often each was used this month (UTC). Read only: the machines
// and their fields live in the code, so old entries stay valid; a new machine is a normal code change.
[Route("api/admin/cardio")]
[Authorize(Policy = AuthenticationExtensions.AdminPolicy)]
public class AdminCardioController(FitPlanDbContext context, TimeProvider time) : ApiControllerBase
{
    [HttpGet]
    public async Task<IActionResult> List()
    {
        var now = time.GetUtcNow().UtcDateTime;
        var monthStart = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var uses = await context.CardioEntries
            .Where(c => c.RecordedAt >= monthStart)
            .GroupBy(c => c.Machine)
            .Select(g => new { Machine = g.Key, Count = g.Count() })
            .ToDictionaryAsync(g => g.Machine, g => g.Count);

        // Other is retired; it shows only while it still has entries this month
        var machines = Enum.GetValues<CardioMachine>()
            .Where(m => m != CardioMachine.Other || uses.ContainsKey(m))
            .Select(m => new AdminCardioMachineDto(m.ToString(), CardioFields.For(m), uses.GetValueOrDefault(m)));
        return Ok(machines);
    }
}
