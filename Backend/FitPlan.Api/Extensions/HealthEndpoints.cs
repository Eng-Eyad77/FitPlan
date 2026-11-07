using System.Reflection;
using System.Text.RegularExpressions;

namespace FitPlan.Api.Extensions;

public static partial class HealthEndpoints
{
    private const string UnknownCommit = "unknown";

    // Liveness only. It never touches the database, so calling it can't wake the database or spend its quota.
    public static IEndpointRouteBuilder MapHealthEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var commit = GetBuildCommit();

        endpoints.MapGet("/health/live", () => Results.Ok(new { status = "Healthy", commit }))
            .AllowAnonymous();

        return endpoints;
    }

    // The build stores the commit after the "+" in the informational version: 1.0.0+<sha>.
    private static string GetBuildCommit()
    {
        var version = typeof(HealthEndpoints).Assembly
            .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?
            .InformationalVersion;

        var commit = version?.Split('+').LastOrDefault();

        return commit is not null && CommitSha().IsMatch(commit) ? commit : UnknownCommit;
    }

    [GeneratedRegex("^[0-9a-f]{40}$")]
    private static partial Regex CommitSha();
}
