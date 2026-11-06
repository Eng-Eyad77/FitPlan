using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Cryptography;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Models;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
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

        factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder => builder.UseEnvironment(TestEnvironment));

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

    public HttpClient CreateClient(string? accessToken = null)
    {
        var client = factory.CreateClient();

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

    public static string NewUsername() => "test-" + Guid.NewGuid().ToString("N")[..16];

    public static string NewPassword() => Convert.ToBase64String(RandomNumberGenerator.GetBytes(24));

    public async Task<TestUser> RegisterUserAsync()
    {
        var username = NewUsername();
        var password = NewPassword();

        var response = await CreateClient().PostAsJsonAsync("/api/auth/register", new { username, password });
        response.EnsureSuccessStatusCode();

        var auth = await response.Content.ReadFromJsonAsync<AuthResponseDto>();

        return new TestUser(auth!.Id, username, password, CreateClient(auth.AccessToken));
    }

    public async Task<string> AddExerciseAsync(string name = "Bench Press")
    {
        var id = "test-" + Guid.NewGuid().ToString("N");

        await WithDbContextAsync(async context =>
        {
            context.Exercises.Add(new Exercise
            {
                Id = id,
                Name = name,
                GifUrl = "https://example.test/exercise.gif",
                BodyPart = "chest",
                Instructions = ["Lift", "Lower"]
            });
            await context.SaveChangesAsync();
        });

        return id;
    }
}

public sealed record TestUser(Guid Id, string Username, string Password, HttpClient Client);

// The tests share one database and start real API hosts, which can't safely be built at the same moment.
[CollectionDefinition(Name)]
public sealed class ApiCollection : ICollectionFixture<ApiFixture>
{
    public const string Name = "API";
}
