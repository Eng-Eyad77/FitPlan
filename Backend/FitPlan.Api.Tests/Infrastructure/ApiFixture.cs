using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Cryptography;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Email;
using FitPlan.Api.Services.Reports;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace FitPlan.Api.Tests.Infrastructure;

// Runs the real API in memory against one throwaway database, created for this test run and dropped after it.
// The JWT key and every test password are random, so no secret lives in the repository.
public sealed class ApiFixture : IAsyncLifetime
{
    public const string TestEnvironment = "Testing";
    public const string JwtIssuer = "FitPlan.Api";
    public const string JwtAudience = "FitPlan.Client";

    // Program.cs reads these while it registers services, which is before WebApplicationFactory
    // can add configuration, so they have to be environment variables.
    private const string ConnectionVariable = "ConnectionStrings__FitPlanDb";
    private const string JwtKeyVariable = "Jwt__Key";
    private const string UploadsVariable = "Uploads__Root";

    private WebApplicationFactory<Program> factory = null!;
    private string uploadsRoot = null!;

    public string JwtKey { get; } = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));

    public async Task InitializeAsync()
    {
        uploadsRoot = Directory.CreateTempSubdirectory("fitplan-tests-").FullName;

        Environment.SetEnvironmentVariable(ConnectionVariable, TestDatabase.CreateUniqueConnectionString());
        Environment.SetEnvironmentVariable(JwtKeyVariable, JwtKey);
        Environment.SetEnvironmentVariable(UploadsVariable, uploadsRoot);

        factory = NewHost();

        using var scope = factory.Services.CreateScope();
        await scope.ServiceProvider.GetRequiredService<FitPlanDbContext>().Database.MigrateAsync();
    }

    public async Task DisposeAsync()
    {
        using (var scope = factory.Services.CreateScope())
        {
            await scope.ServiceProvider.GetRequiredService<FitPlanDbContext>().Database.EnsureDeletedAsync();
        }

        await factory.DisposeAsync();

        Environment.SetEnvironmentVariable(ConnectionVariable, null);
        Environment.SetEnvironmentVariable(JwtKeyVariable, null);
        Environment.SetEnvironmentVariable(UploadsVariable, null);
        Directory.Delete(uploadsRoot, recursive: true);
    }

    public IServiceProvider Services => factory.Services;

    // Another API host on the same database. Its exercise catalog is new, so it reads rows a test
    // added after the shared host had loaded its list. The caller disposes it.
    public WebApplicationFactory<Program> NewHost() =>
        new WebApplicationFactory<Program>().WithWebHostBuilder(builder => builder
            .UseEnvironment(TestEnvironment)
            .ConfigureTestServices(services => services
                .AddSingleton<IEmailSender>(Emails)
                .AddSingleton<ITelegramNotifier>(Telegram)));

    // every email the API sends, from every host
    public FakeEmailSender Emails { get; } = new();

    // every Telegram message the API sends, from every host
    public FakeTelegramNotifier Telegram { get; } = new();

    public string UploadsRoot => uploadsRoot;

    public HttpClient CreateClient(string? accessToken = null)
    {
        var client = factory.CreateClient();

        // Each client is a different caller, so the per-IP sign-in limit doesn't spill between tests.
        client.DefaultRequestHeaders.Add("X-Forwarded-For", NewCallerIp());

        if (accessToken is not null)
        {
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        }

        return client;
    }

    public async Task WithDbContextAsync(Func<FitPlanDbContext, Task> action)
    {
        using var scope = factory.Services.CreateScope();
        await action(scope.ServiceProvider.GetRequiredService<FitPlanDbContext>());
    }

    public async Task<T> WithDbContextAsync<T>(Func<FitPlanDbContext, Task<T>> action)
    {
        using var scope = factory.Services.CreateScope();
        return await action(scope.ServiceProvider.GetRequiredService<FitPlanDbContext>());
    }

    // 198.18.0.0/15 is reserved for testing.
    public static string NewCallerIp() =>
        $"198.{18 + Random.Shared.Next(2)}.{Random.Shared.Next(256)}.{Random.Shared.Next(1, 255)}";

    public static string NewUsername() => "test-" + Guid.NewGuid().ToString("N")[..16];

    public static string NewPassword() => Convert.ToBase64String(RandomNumberGenerator.GetBytes(24));

    public static string NewEmail() => NewUsername() + "@example.test";

    // Both sign-up steps: asks for the code, then signs up with the code from the fake inbox.
    public async Task<HttpResponseMessage> SignUpAsync(string email, string username, string password)
    {
        var client = CreateClient();
        (await client.PostAsJsonAsync("/api/auth/register/code", new { email })).EnsureSuccessStatusCode();

        return await client.PostAsJsonAsync("/api/auth/register", new { email, code = Emails.LastCode(email), username, password });
    }

    public async Task<TestUser> RegisterUserAsync()
    {
        var email = NewEmail();
        var username = NewUsername();
        var password = NewPassword();

        var response = await SignUpAsync(email, username, password);
        response.EnsureSuccessStatusCode();

        var auth = await response.Content.ReadFromJsonAsync<AuthResponseDto>();

        return new TestUser(auth!.Id, username, email, password, CreateClient(auth.AccessToken));
    }

    public async Task<string> AddExerciseAsync(string name = "Bench Press", string bodyPart = "chest")
    {
        var id = "test-" + Guid.NewGuid().ToString("N");

        await WithDbContextAsync(async context =>
        {
            context.Exercises.Add(new Exercise
            {
                Id = id,
                Name = name,
                GifUrl = "https://example.test/exercise.gif",
                BodyPart = bodyPart,
                Instructions = ["Lift", "Lower"]
            });
            await context.SaveChangesAsync();
        });

        return id;
    }
}

public sealed record TestUser(Guid Id, string Username, string Email, string Password, HttpClient Client);

// The tests share one database and start real API hosts, which can't safely be built at the same moment.
[CollectionDefinition(Name)]
public sealed class ApiCollection : ICollectionFixture<ApiFixture>
{
    public const string Name = "API";
}
