using System.Globalization;
using System.Net;
using System.Security.Claims;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace FitPlan.Api.Extensions;

public static class RateLimitingExtensions
{
    public const string ExercisesPolicy = "exercises";
    public const int ExercisesPermitPerMinute = 120;

    // The exercise library is open without signing in, so one caller could flood it.
    // Each signed-in user, or each IP address otherwise, gets ExercisesPermitPerMinute requests a minute.
    public static IServiceCollection AddRateLimits(this IServiceCollection services)
    {
        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

            options.AddPolicy(ExercisesPolicy, context => RateLimitPartition.GetFixedWindowLimiter(
                PartitionKey(context),
                _ => new FixedWindowRateLimiterOptions
                {
                    PermitLimit = ExercisesPermitPerMinute,
                    Window = TimeSpan.FromMinutes(1),
                    QueueLimit = 0
                }));

            options.OnRejected = async (context, cancellationToken) =>
            {
                var retryAfter = context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var wait)
                    ? (int)Math.Ceiling(wait.TotalSeconds)
                    : 60;
                context.HttpContext.Response.Headers.RetryAfter = retryAfter.ToString(CultureInfo.InvariantCulture);

                var problems = context.HttpContext.RequestServices.GetRequiredService<IProblemDetailsService>();
                await problems.TryWriteAsync(new ProblemDetailsContext
                {
                    HttpContext = context.HttpContext,
                    ProblemDetails = new ProblemDetails
                    {
                        Status = StatusCodes.Status429TooManyRequests,
                        Title = "Too many requests. Wait a moment and try again.",
                        Extensions = { ["errorCode"] = "TooManyRequests" }
                    }
                });
            };
        });

        return services;
    }

    public static string PartitionKey(HttpContext context)
    {
        var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier);
        return userId is not null ? $"user:{userId}" : $"ip:{ClientIp(context)}";
    }

    // App Service's front end adds the caller's address as the last X-Forwarded-For entry,
    // so earlier entries, which a caller can write themselves, are ignored.
    public static string ClientIp(HttpContext context)
    {
        var forwarded = context.Request.Headers["X-Forwarded-For"].ToString();
        var last = forwarded.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).LastOrDefault();

        if (last is not null)
        {
            // "203.0.113.7:51234" or "[2001:db8::1]:51234" -> the address without the port
            if (IPEndPoint.TryParse(last, out var endpoint))
            {
                return endpoint.Address.ToString();
            }

            if (IPAddress.TryParse(last, out var address))
            {
                return address.ToString();
            }
        }

        return context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
    }
}
