
using FitPlan.Api.Common.Exceptions;

namespace FitPlan.Api.Extensions;

public static class ErrorHandlingExtensions
{
    public static IServiceCollection AddErrorHandling(
        this IServiceCollection services)
    {
        // Every error response (ours, validation, 401, 500...) uses the ProblemDetails format,
        // and always carries an "errorCode" the client can switch on.
        services.AddProblemDetails(options =>
        {
            options.CustomizeProblemDetails = context =>
            {
                context.ProblemDetails.Extensions.TryAdd("errorCode", context.ProblemDetails.Status switch
                {
                    StatusCodes.Status400BadRequest => "ValidationFailed",
                    StatusCodes.Status401Unauthorized => "Unauthorized",
                    StatusCodes.Status403Forbidden => "Forbidden",
                    StatusCodes.Status404NotFound => "NotFound",
                    StatusCodes.Status500InternalServerError => "InternalServerError",
                    _ => "RequestFailed"
                });
            };
        });

        services.AddExceptionHandler<GlobalExceptionHandler>();

        return services;
    }
}
