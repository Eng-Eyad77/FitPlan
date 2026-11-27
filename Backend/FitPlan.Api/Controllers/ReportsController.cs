using FitPlan.Api.DTOs.Reports;
using FitPlan.Api.Extensions;
using FitPlan.Api.Services.Exercises;
using FitPlan.Api.Services.Reports;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace FitPlan.Api.Controllers;

// D14: signed-in users report a problem from Profile.
[Authorize]
[Route("api/reports")]
public class ReportsController(IProblemReportService reports) : ApiControllerBase
{
    [HttpPost]
    [EnableRateLimiting(RateLimitingExtensions.ReportsPolicy)]
    public async Task<IActionResult> Create(CreateProblemReportDto request)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var result = await reports.CreateAsync(userId, request, ContentLanguage.From(Request));

        return result.IsSuccess ? StatusCode(StatusCodes.Status201Created, result.Data) : Problem(result.Error);
    }
}
