
using System.Security.Claims;
using FitPlan.Api.Common.Results;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

// Shared helpers for all the API controllers.
[ApiController]
public abstract class ApiControllerBase : ControllerBase
{
    // Reads the authenticated user id from the JWT (ClaimTypes.NameIdentifier).
    protected bool TryGetUserId(out Guid userId) =>
        Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);


    // Converts a business Error into a ProblemDetails response, the standard error format (RFC 9457):
    // { "status": 404, "title": "Workout plan not found.", "errorCode": "WorkoutPlanNotFound", "traceId": "..." }
    protected IActionResult Problem(Error error)
    {
        var statusCode = error.Type switch
        {
            ErrorType.Validation => StatusCodes.Status400BadRequest,
            ErrorType.Unauthorized => StatusCodes.Status401Unauthorized,
            ErrorType.NotFound => StatusCodes.Status404NotFound,
            ErrorType.Conflict => StatusCodes.Status409Conflict,
            ErrorType.PayloadTooLarge => StatusCodes.Status413PayloadTooLarge,
            _ => StatusCodes.Status500InternalServerError
        };

        var problemDetails = ProblemDetailsFactory.CreateProblemDetails(HttpContext, statusCode, title: error.Message);

        problemDetails.Extensions["errorCode"] = error.Code;

        return new ObjectResult(problemDetails) { StatusCode = statusCode };
    }
}
