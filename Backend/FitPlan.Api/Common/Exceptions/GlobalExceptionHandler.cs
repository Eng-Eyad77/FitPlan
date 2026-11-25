using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore.Storage;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Admin;

namespace FitPlan.Api.Common.Exceptions;

// Catches any exception that was not handled anywhere else,
// logs it, and returns a clean ProblemDetails instead of leaking the stack trace.
// A database that is still waking up gets 503 "DatabaseUnavailable", so the app can say so;
// everything else is a 500.
public sealed class GlobalExceptionHandler(
    ILogger<GlobalExceptionHandler> logger,
    IProblemDetailsService problemDetailsService,
    ServerEventLog events) : IExceptionHandler
{
    public const string DatabaseUnavailableCode = "DatabaseUnavailable";
    public const int RetryAfterSeconds = 10;

    // SQL errors that mean "the database can't be reached right now", not "the request is wrong".
    // 40613: database not currently available (a paused serverless database while it resumes).
    // 40197, 40501, 49918-49920: the service is busy or reconfiguring. -2: the query timed out.
    private static readonly HashSet<int> UnavailableSqlErrors = [40613, 40197, 40501, 49918, 49919, 49920, -2];

    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        var databaseUnavailable = IsDatabaseUnavailable(exception);

        if (databaseUnavailable)
        {
            logger.LogWarning(
                exception,
                "Database unavailable while processing {Method} {Path}",
                httpContext.Request.Method,
                httpContext.Request.Path);
        }
        else
        {
            logger.LogError(
                exception,
                "Unhandled exception while processing {Method} {Path}",
                httpContext.Request.Method,
                httpContext.Request.Path);
            // a sleeping database is expected on the free plan, and couldn't take the write anyway
            await events.RecordAsync(ServerEventKind.ApiError, ServerEventLog.Endpoint(httpContext), exception.GetType().Name, httpContext);
        }

        var status = databaseUnavailable
            ? StatusCodes.Status503ServiceUnavailable
            : StatusCodes.Status500InternalServerError;

        httpContext.Response.StatusCode = status;

        var problem = new ProblemDetails
        {
            Status = status,
            Title = databaseUnavailable
                ? "The server is starting up. Try again in a moment."
                : "An unexpected error occurred."
        };

        if (databaseUnavailable)
        {
            httpContext.Response.Headers.RetryAfter = RetryAfterSeconds.ToString();
            problem.Extensions["errorCode"] = DatabaseUnavailableCode;
        }

        return await problemDetailsService.TryWriteAsync(new ProblemDetailsContext
        {
            HttpContext = httpContext,
            Exception = exception,
            ProblemDetails = problem
        });
    }

    // True when EF gave up retrying, or a SQL error in the chain means the database is unreachable.
    public static bool IsDatabaseUnavailable(Exception exception)
    {
        for (var current = exception; current is not null; current = current.InnerException)
        {
            switch (current)
            {
                case RetryLimitExceededException:
                    return true;
                case SqlException sql when sql.Errors.Cast<SqlError>().Any(e => UnavailableSqlErrors.Contains(e.Number)):
                    return true;
            }
        }

        return false;
    }
}
