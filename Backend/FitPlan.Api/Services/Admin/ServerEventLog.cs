using System.Diagnostics;
using FitPlan.Api.Data;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.Admin;

// Writes ServerEvents in a scope of its own, so a request whose database context is in a bad state
// can still be recorded. Never throws: a failed write is only logged.
public class ServerEventLog(IServiceScopeFactory scopes, TimeProvider time, ILogger<ServerEventLog> logger)
{
    public static readonly TimeSpan KeptFor = TimeSpan.FromDays(30);

    public async Task RecordAsync(ServerEventKind kind, string detail, string reason, HttpContext? http = null)
    {
        try
        {
            await using var scope = scopes.CreateAsyncScope();
            var context = scope.ServiceProvider.GetRequiredService<FitPlanDbContext>();
            var now = time.GetUtcNow().UtcDateTime;

            await context.ServerEvents.Where(e => e.CreatedAt < now - KeptFor).ExecuteDeleteAsync();
            context.ServerEvents.Add(new ServerEvent
            {
                Kind = kind,
                Detail = Cut(detail, 200),
                Reason = Cut(reason, 100),
                RequestId = http is null ? null : RequestId(http),
                CreatedAt = now
            });
            await context.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Couldn't record a {Kind} server event", kind);
        }
    }

    // the same value ASP.NET puts in the "traceId" of every error response
    public static string RequestId(HttpContext http) => Activity.Current?.Id ?? http.TraceIdentifier;

    // "POST /api/sessions/{id}/complete": the route, so ids and query strings are left out
    public static string Endpoint(HttpContext http)
    {
        var route = (http.GetEndpoint() as RouteEndpoint)?.RoutePattern.RawText;
        return $"{http.Request.Method} {(route is null ? http.Request.Path.Value : "/" + route.TrimStart('/'))}";
    }

    private static string Cut(string text, int max) => text.Length <= max ? text : text[..max];
}
