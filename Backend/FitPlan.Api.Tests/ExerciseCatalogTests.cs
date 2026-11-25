using System.Net;
using System.Net.Http.Json;
using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.Exercises;
using FitPlan.Api.Extensions;
using FitPlan.Api.Services.Exercises;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace FitPlan.Api.Tests;

[Collection(ApiCollection.Name)]
public class ExerciseCatalogTests(ApiFixture api)
{
    private sealed class ManualClock : TimeProvider
    {
        public DateTimeOffset Now { get; set; } = new(2026, 11, 16, 12, 0, 0, TimeSpan.Zero);
        public override DateTimeOffset GetUtcNow() => Now;
    }

    // Counts database reads, and can be told to fail them, like a database that can't be reached.
    private sealed class CountingScopes(IServiceScopeFactory inner) : IServiceScopeFactory
    {
        public int Reads;
        public bool Fail;

        public IServiceScope CreateScope()
        {
            Interlocked.Increment(ref Reads);
            return Fail ? throw new InvalidOperationException("database unreachable") : inner.CreateScope();
        }
    }

    private (ExerciseCatalog Catalog, CountingScopes Scopes, ManualClock Clock) NewCatalog(
        string? cacheFile = null, ManualClock? clock = null)
    {
        var scopes = new CountingScopes(api.Services.GetRequiredService<IServiceScopeFactory>());
        clock ??= new ManualClock();
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection([new(ExerciseCatalog.CacheFileSetting, cacheFile)])
            .Build();
        return (new ExerciseCatalog(scopes, clock, NullLogger<ExerciseCatalog>.Instance, configuration), scopes, clock);
    }

    private static string NewCacheFile() =>
        Path.Combine(Path.GetTempPath(), "fitplan-tests-" + Guid.NewGuid().ToString("N"), "cache", "exercises.json");

    private static void DeleteCacheFile(string file) => Directory.Delete(Path.GetDirectoryName(Path.GetDirectoryName(file))!, recursive: true);

    private Task DeleteExerciseAsync(string id) =>
        api.WithDbContextAsync(context => context.Exercises.Where(e => e.Id == id).ExecuteDeleteAsync());

    [Fact]
    public async Task The_database_is_read_once_and_then_served_from_memory()
    {
        var id = await api.AddExerciseAsync("Cached " + Guid.NewGuid().ToString("N"));
        var (catalog, scopes, _) = NewCatalog();

        Assert.Contains(id, (await catalog.GetAsync()).ById.Keys);
        await DeleteExerciseAsync(id);

        Assert.Contains(id, (await catalog.GetAsync()).ById.Keys);
        Assert.Equal(1, scopes.Reads);
    }

    [Fact]
    public async Task The_list_is_read_again_after_the_refresh_time()
    {
        var id = await api.AddExerciseAsync("Refreshed " + Guid.NewGuid().ToString("N"));
        var (catalog, scopes, clock) = NewCatalog();
        await catalog.GetAsync();
        await DeleteExerciseAsync(id);

        clock.Now += ExerciseCatalog.RefreshAfter - TimeSpan.FromSeconds(1);
        Assert.Contains(id, (await catalog.GetAsync()).ById.Keys);

        clock.Now += TimeSpan.FromSeconds(1);
        Assert.DoesNotContain(id, (await catalog.GetAsync()).ById.Keys);
        Assert.Equal(2, scopes.Reads);
    }

    [Fact]
    public async Task Many_requests_at_once_read_the_database_only_once()
    {
        var (catalog, scopes, _) = NewCatalog();

        await Task.WhenAll(Enumerable.Range(0, 20).Select(_ => catalog.GetAsync()));

        Assert.Equal(1, scopes.Reads);
    }

    [Fact]
    public async Task A_failed_refresh_keeps_serving_the_last_list()
    {
        var id = await api.AddExerciseAsync("Kept " + Guid.NewGuid().ToString("N"));
        var (catalog, scopes, clock) = NewCatalog();
        await catalog.GetAsync();

        scopes.Fail = true;
        clock.Now += ExerciseCatalog.RefreshAfter;

        Assert.Contains(id, (await catalog.GetAsync()).ById.Keys);
    }

    [Fact]
    public async Task With_no_list_yet_a_database_failure_reaches_the_caller()
    {
        var (catalog, scopes, _) = NewCatalog();
        scopes.Fail = true;

        await Assert.ThrowsAsync<InvalidOperationException>(() => catalog.GetAsync());
    }

    [Fact]
    public async Task After_a_restart_the_saved_file_is_served_without_reading_the_database()
    {
        var file = NewCacheFile();
        try
        {
            var id = await api.AddExerciseAsync("Saved " + Guid.NewGuid().ToString("N"));
            var clock = new ManualClock();
            await NewCatalog(file, clock).Catalog.GetAsync();
            await DeleteExerciseAsync(id);

            clock.Now += ExerciseCatalog.RefreshAfter - TimeSpan.FromSeconds(1);
            var (restarted, scopes, _) = NewCatalog(file, clock);

            Assert.Contains(id, (await restarted.GetAsync()).ById.Keys);
            Assert.Equal(0, scopes.Reads);
        }
        finally
        {
            DeleteCacheFile(file);
        }
    }

    [Fact]
    public async Task An_old_saved_file_is_replaced_from_the_database()
    {
        var file = NewCacheFile();
        try
        {
            var id = await api.AddExerciseAsync("Old " + Guid.NewGuid().ToString("N"));
            var clock = new ManualClock();
            await NewCatalog(file, clock).Catalog.GetAsync();
            await DeleteExerciseAsync(id);

            clock.Now += ExerciseCatalog.RefreshAfter;
            var (restarted, scopes, _) = NewCatalog(file, clock);
            Assert.DoesNotContain(id, (await restarted.GetAsync()).ById.Keys);
            Assert.Equal(1, scopes.Reads);

            // the new list was saved, so the next start reads nothing either
            var (again, againScopes, _) = NewCatalog(file, clock);
            Assert.DoesNotContain(id, (await again.GetAsync()).ById.Keys);
            Assert.Equal(0, againScopes.Reads);
        }
        finally
        {
            DeleteCacheFile(file);
        }
    }

    [Fact]
    public async Task An_old_saved_file_is_served_when_the_database_fails()
    {
        var file = NewCacheFile();
        try
        {
            var id = await api.AddExerciseAsync("Fallback " + Guid.NewGuid().ToString("N"));
            var clock = new ManualClock();
            await NewCatalog(file, clock).Catalog.GetAsync();

            clock.Now += ExerciseCatalog.RefreshAfter * 3;
            var (restarted, scopes, _) = NewCatalog(file, clock);
            scopes.Fail = true;

            Assert.Contains(id, (await restarted.GetAsync()).ById.Keys);
        }
        finally
        {
            DeleteCacheFile(file);
        }
    }

    [Fact]
    public async Task A_broken_saved_file_is_ignored_and_the_database_is_read()
    {
        var file = NewCacheFile();
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(file)!);
            await File.WriteAllTextAsync(file, "{ not json");
            var id = await api.AddExerciseAsync("Broken " + Guid.NewGuid().ToString("N"));
            var (catalog, scopes, _) = NewCatalog(file);

            Assert.Contains(id, (await catalog.GetAsync()).ById.Keys);
            Assert.Equal(1, scopes.Reads);
        }
        finally
        {
            DeleteCacheFile(file);
        }
    }

    [Fact]
    public async Task A_saved_file_dated_in_the_future_is_treated_as_old()
    {
        var file = NewCacheFile();
        try
        {
            var clock = new ManualClock();
            await NewCatalog(file, clock).Catalog.GetAsync();

            clock.Now -= TimeSpan.FromHours(1);
            var (restarted, scopes, _) = NewCatalog(file, clock);
            await restarted.GetAsync();

            Assert.Equal(1, scopes.Reads);
        }
        finally
        {
            DeleteCacheFile(file);
        }
    }

    [Fact]
    public async Task Search_ignores_case_and_ranks_exact_then_prefix_then_contains()
    {
        var tag = Guid.NewGuid().ToString("N")[..10];
        await api.AddExerciseAsync($"Incline {tag} Press");
        await api.AddExerciseAsync($"{tag} Row");
        await api.AddExerciseAsync(tag);
        var service = new ExerciseService(NewCatalog().Catalog, new ConfigurationBuilder().Build());

        var result = await service.GetAllExercisesAsync(1, 10, bodyPart: "CHEST", search: tag.ToUpperInvariant());

        Assert.Equal(3, result.TotalCount);
        Assert.Equal([tag, $"{tag} Row", $"Incline {tag} Press"], result.Items.Select(e => e.Name));
    }

    [Fact]
    public async Task Search_words_match_in_any_order_after_the_closer_matches()
    {
        var tag = Guid.NewGuid().ToString("N")[..10];
        await api.AddExerciseAsync($"Incline {tag} Press");
        await api.AddExerciseAsync($"{tag} Incline");
        var service = new ExerciseService(NewCatalog().Catalog, new ConfigurationBuilder().Build());

        var result = await service.GetAllExercisesAsync(1, 10, bodyPart: null, search: $"{tag} incline");

        Assert.Equal([$"{tag} Incline", $"Incline {tag} Press"], result.Items.Select(e => e.Name));
    }

    [Fact]
    public async Task Pages_split_the_matches()
    {
        var tag = Guid.NewGuid().ToString("N")[..10];
        for (var i = 0; i < 3; i++)
        {
            await api.AddExerciseAsync($"{tag} {i}");
        }
        var service = new ExerciseService(NewCatalog().Catalog, new ConfigurationBuilder().Build());

        var second = await service.GetAllExercisesAsync(page: 2, pageSize: 2, bodyPart: null, search: tag);

        Assert.Equal((3, 2), (second.TotalCount, second.TotalPages));
        Assert.Single(second.Items);
    }

    [Fact]
    public async Task An_exercise_is_found_by_id_and_a_missing_one_is_not()
    {
        var id = await api.AddExerciseAsync();
        var service = new ExerciseService(NewCatalog().Catalog, new ConfigurationBuilder().Build());

        Assert.True((await service.GetExerciseByIdAsync(id.ToUpperInvariant())).IsSuccess);
        Assert.Equal(Errors.ExerciseNotFound, (await service.GetExerciseByIdAsync("no-such-id")).Error);
    }

    [Fact]
    public async Task Too_many_exercise_requests_get_429_with_Retry_After()
    {
        var client = api.CreateClient();
        // a caller address used by no other test, so the limit starts fresh
        client.DefaultRequestHeaders.Add("X-Forwarded-For", $"198.51.100.{Random.Shared.Next(1, 254)}");

        for (var i = 0; i < RateLimitingExtensions.ExercisesPermitPerMinute; i++)
        {
            var ok = await client.GetAsync("/api/exercises?pageSize=1");
            Assert.Equal(HttpStatusCode.OK, ok.StatusCode);
        }

        var limited = await client.GetAsync("/api/exercises?pageSize=1");

        await limited.AssertProblemAsync(HttpStatusCode.TooManyRequests, "TooManyRequests");
        Assert.True(limited.Headers.RetryAfter is not null);
    }

    [Theory]
    [InlineData("1.2.3.4, 203.0.113.7:51234", "203.0.113.7")]
    [InlineData("203.0.113.7", "203.0.113.7")]
    [InlineData("[2001:db8::1]:443", "2001:db8::1")]
    public void The_caller_is_the_last_forwarded_address(string forwarded, string expected)
    {
        var context = new DefaultHttpContext();
        context.Request.Headers["X-Forwarded-For"] = forwarded;

        Assert.Equal(expected, RateLimitingExtensions.ClientIp(context));
    }

    [Fact]
    public void Without_a_forwarded_header_the_connection_address_is_used()
    {
        var context = new DefaultHttpContext();
        context.Connection.RemoteIpAddress = IPAddress.Parse("192.0.2.10");

        Assert.Equal("192.0.2.10", RateLimitingExtensions.ClientIp(context));
    }
}
