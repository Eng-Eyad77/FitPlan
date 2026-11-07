using System.Net;
using System.Text.Json;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace FitPlan.Api.Tests;

[Collection(ApiCollection.Name)]
public class HealthEndpointTests(ApiFixture api)
{
    private const string Route = "/health/live";
    private const string ConnectionVariable = "ConnectionStrings__FitPlanDb";

    // CI sets this to the commit it passed to the build.
    private const string ExpectedCommitVariable = "FITPLAN_EXPECTED_COMMIT";

    [Fact]
    public async Task Answers_without_a_token_with_only_the_status_and_the_commit()
    {
        var response = await api.CreateClient().GetAsync(Route);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(["status", "commit"], body.RootElement.EnumerateObject().Select(p => p.Name));
        Assert.Equal("Healthy", body.RootElement.GetProperty("status").GetString());
    }

    [Fact]
    public async Task Reports_the_commit_the_API_was_built_from()
    {
        var commit = await ReadCommitAsync(api.CreateClient());

        var expected = Environment.GetEnvironmentVariable(ExpectedCommitVariable);
        if (string.IsNullOrEmpty(expected))
        {
            // A local build takes the commit from Git, or has none outside a repository.
            Assert.Matches("^([0-9a-f]{40}|unknown)$", commit);
        }
        else
        {
            Assert.Equal(expected, commit);
        }
    }

    [Fact]
    public async Task Stays_healthy_when_the_database_can_not_be_reached()
    {
        var original = Environment.GetEnvironmentVariable(ConnectionVariable);
        Environment.SetEnvironmentVariable(
            ConnectionVariable,
            "Server=127.0.0.1,1;Database=FitPlanTests_unreachable;User ID=none;Connect Timeout=1;");

        try
        {
            using var factory = new WebApplicationFactory<Program>()
                .WithWebHostBuilder(builder => builder.UseEnvironment(ApiFixture.TestEnvironment));

            var response = await factory.CreateClient().GetAsync(Route);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        }
        finally
        {
            Environment.SetEnvironmentVariable(ConnectionVariable, original);
        }
    }

    private static async Task<string?> ReadCommitAsync(HttpClient client)
    {
        using var body = JsonDocument.Parse(await client.GetStringAsync(Route));
        return body.RootElement.GetProperty("commit").GetString();
    }
}
