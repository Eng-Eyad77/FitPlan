using FitPlan.Api.Tests.Infrastructure;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace FitPlan.Api.Tests;

// Only the hosted admin site may call from a browser, plus localhost on Dev and locally.
[Collection(ApiCollection.Name)]
public class CorsTests
{
    private const string Admin = "https://admin-dev.fitplan-app.com";

    [Theory]
    [InlineData(ApiFixture.TestEnvironment, Admin, true)]
    [InlineData(ApiFixture.TestEnvironment, "https://admin-dev.fitplan-app.com.evil.test", false)]
    [InlineData(ApiFixture.TestEnvironment, "http://localhost:8086", false)]
    [InlineData("Development", Admin, true)]
    [InlineData("Development", "http://localhost:8086", true)]
    [InlineData("Development", "https://someone-else.test", false)]
    public async Task Only_the_admin_site_and_localhost_where_allowed_may_call(string environment, string origin, bool allowed)
    {
        using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder => builder
            .UseEnvironment(environment)
            .UseSetting("Cors:AdminOrigin", Admin + "/"));
        using var preflight = new HttpRequestMessage(HttpMethod.Options, "/api/admin/auth/login");
        preflight.Headers.Add("Origin", origin);
        preflight.Headers.Add("Access-Control-Request-Method", "POST");

        var response = await factory.CreateClient().SendAsync(preflight);

        Assert.Equal(allowed, response.Headers.TryGetValues("Access-Control-Allow-Origin", out var values) && values.Single() == origin);
    }
}
