using System.Net;
using System.Text.Json;
using Xunit;

namespace FitPlan.Api.Tests.Infrastructure;

public static class HttpAssertions
{
    // Business errors come back as ProblemDetails with an errorCode the app relies on.
    public static async Task AssertProblemAsync(this HttpResponseMessage response, HttpStatusCode status, string errorCode)
    {
        Assert.Equal(status, response.StatusCode);

        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(errorCode, body.RootElement.GetProperty("errorCode").GetString());
    }
}
