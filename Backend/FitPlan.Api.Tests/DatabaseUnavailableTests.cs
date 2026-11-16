using System.Text.Json;
using FitPlan.Api.Common.Exceptions;
using FitPlan.Api.Data;
using FitPlan.Api.Extensions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting.Internal;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace FitPlan.Api.Tests;

// No database is opened here. A real paused database is only checked on Dev.
public class DatabaseUnavailableTests
{
    [Fact]
    public void Retry_is_enabled_for_the_API_database()
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["ConnectionStrings:FitPlanDb"] = "Server=localhost;Database=NotOpened;Trusted_Connection=True;"
            })
            .Build();

        var services = new ServiceCollection();
        services.AddDatabase(configuration, new HostingEnvironment { EnvironmentName = "Production" });
        using var provider = services.BuildServiceProvider();
        using var context = provider.GetRequiredService<FitPlanDbContext>();

        Assert.True(context.Database.CreateExecutionStrategy().RetriesOnFailure);
    }

    [Fact]
    public void Giving_up_after_retries_means_the_database_is_unavailable()
    {
        Assert.True(GlobalExceptionHandler.IsDatabaseUnavailable(new RetryLimitExceededException("gave up")));
    }

    [Fact]
    public void A_wrapped_retry_failure_is_still_found()
    {
        var wrapped = new DbUpdateException("save failed", new RetryLimitExceededException("gave up"));

        Assert.True(GlobalExceptionHandler.IsDatabaseUnavailable(wrapped));
    }

    [Fact]
    public void Other_errors_are_not_treated_as_an_unavailable_database()
    {
        Assert.False(GlobalExceptionHandler.IsDatabaseUnavailable(new InvalidOperationException("bug")));
        Assert.False(GlobalExceptionHandler.IsDatabaseUnavailable(new DbUpdateException("constraint")));
    }

    [Fact]
    public async Task An_unavailable_database_returns_503_with_its_code_and_Retry_After()
    {
        var (status, headers, body) = await HandleAsync(new RetryLimitExceededException("gave up"));

        Assert.Equal(StatusCodes.Status503ServiceUnavailable, status);
        Assert.Equal(GlobalExceptionHandler.RetryAfterSeconds.ToString(), headers.RetryAfter.ToString());
        Assert.Equal(GlobalExceptionHandler.DatabaseUnavailableCode, body.GetProperty("errorCode").GetString());
    }

    [Fact]
    public async Task Any_other_failure_stays_a_500()
    {
        var (status, headers, body) = await HandleAsync(new InvalidOperationException("bug"));

        Assert.Equal(StatusCodes.Status500InternalServerError, status);
        Assert.False(headers.ContainsKey("Retry-After"));
        Assert.Equal("InternalServerError", body.GetProperty("errorCode").GetString());
    }

    private static async Task<(int Status, IHeaderDictionary Headers, JsonElement Body)> HandleAsync(Exception exception)
    {
        var services = new ServiceCollection();
        services.AddLogging();
        services.AddErrorHandling();
        await using var provider = services.BuildServiceProvider();

        var context = new DefaultHttpContext { RequestServices = provider };
        context.Request.Method = "GET";
        context.Request.Path = "/api/exercises";
        context.Request.Headers.Accept = "application/json";
        context.Response.Body = new MemoryStream();

        var handler = new GlobalExceptionHandler(
            NullLogger<GlobalExceptionHandler>.Instance,
            provider.GetRequiredService<IProblemDetailsService>());

        Assert.True(await handler.TryHandleAsync(context, exception, CancellationToken.None));

        context.Response.Body.Position = 0;
        using var document = await JsonDocument.ParseAsync(context.Response.Body);
        return (context.Response.StatusCode, context.Response.Headers, document.RootElement.Clone());
    }
}
