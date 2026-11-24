using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using FitPlan.Api.DTOs.Stats;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Models;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 10: lifetime volume and its milestones.
[Collection(ApiCollection.Name)]
public class VolumeTests(ApiFixture api)
{
    private const string Sessions = "/api/sessions";
    private const string Volume = "/api/stats/volume";

    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() }
    };

    [Fact]
    public async Task A_new_user_has_no_volume_and_every_milestone_locked()
    {
        var user = await api.RegisterUserAsync();

        var volume = await GetVolumeAsync(user);

        Assert.Equal(0m, volume.TotalVolumeKg);
        Assert.Equal(7, volume.Milestones.Length);
        Assert.All(volume.Milestones, m => Assert.Null(m.ReachedAt));
        Assert.Equal(volume.Milestones.OrderBy(m => m.ThresholdKg).Select(m => m.Key), volume.Milestones.Select(m => m.Key));
    }

    [Fact]
    public async Task The_total_counts_finished_weighted_sets_only()
    {
        var user = await api.RegisterUserAsync();

        // 10 × 50 + 8 × 60 = 980, plus a bodyweight set that counts as 0
        await FinishWorkoutAsync(user, (10, 50m), (8, 60m), (15, null));

        // still in progress: not counted
        var open = await StartAsync(user);
        var exercise = await AddExerciseAsync(user, open.Id);
        await AddSetAsync(user, open.Id, exercise.Id, 10, 100m);

        var volume = await GetVolumeAsync(user);

        Assert.Equal(980m, volume.TotalVolumeKg);
    }

    [Fact]
    public async Task Finishing_returns_the_milestones_this_workout_crossed_once()
    {
        var user = await api.RegisterUserAsync();

        // 600 kg: the piano
        var first = await FinishWorkoutAsync(user, (10, 60m));
        Assert.Equal(["grand-piano"], first.NewMilestones);

        // 1,200 kg: the car, the piano is not celebrated again
        var second = await FinishWorkoutAsync(user, (10, 60m));
        Assert.Equal(["small-car"], second.NewMilestones);

        // 1,250 kg: nothing new
        var third = await FinishWorkoutAsync(user, (5, 10m));
        Assert.Empty(third.NewMilestones);

        var volume = await GetVolumeAsync(user);
        Assert.Equal(1_250m, volume.TotalVolumeKg);
        Assert.NotNull(Milestone(volume, "grand-piano").ReachedAt);
        Assert.NotNull(Milestone(volume, "small-car").ReachedAt);
        Assert.Null(Milestone(volume, "elephant").ReachedAt);
    }

    [Fact]
    public async Task One_big_workout_can_cross_several_milestones()
    {
        var user = await api.RegisterUserAsync();

        // 6,000 kg in one go
        var summary = await FinishWorkoutAsync(user, (20, 100m), (20, 100m), (20, 100m));

        Assert.Equal(["grand-piano", "small-car", "elephant"], summary.NewMilestones);
    }

    [Fact]
    public async Task A_deleted_workout_lowers_the_total_but_the_milestone_stays()
    {
        var user = await api.RegisterUserAsync();
        var summary = await FinishWorkoutAsync(user, (10, 120m));
        Assert.Equal(["grand-piano", "small-car"], summary.NewMilestones);

        (await user.Client.DeleteAsync($"{Sessions}/{summary.Id}")).EnsureSuccessStatusCode();

        var volume = await GetVolumeAsync(user);
        Assert.Equal(0m, volume.TotalVolumeKg);
        Assert.NotNull(Milestone(volume, "grand-piano").ReachedAt);
        Assert.NotNull(Milestone(volume, "small-car").ReachedAt);

        // passing it again is not a second celebration
        var again = await FinishWorkoutAsync(user, (10, 120m));
        Assert.Empty(again.NewMilestones);
    }

    [Fact]
    public async Task Older_history_is_back_filled_quietly_with_the_date_it_was_crossed()
    {
        var user = await api.RegisterUserAsync();
        var exerciseId = await api.AddExerciseAsync();
        var march = new DateTime(2026, 3, 10, 18, 0, 0, DateTimeKind.Utc);
        var april = new DateTime(2026, 4, 2, 18, 0, 0, DateTimeKind.Utc);

        // two workouts finished before this feature existed: 500 kg, then 6,000 kg more
        await AddHistoryAsync(user.Id, exerciseId, march, 500m);
        await AddHistoryAsync(user.Id, exerciseId, april, 6_000m);

        // the first workout after the update crosses only the bus
        var summary = await FinishWorkoutAsync(user, (55, 100m));

        Assert.Equal(["city-bus"], summary.NewMilestones);

        var volume = await GetVolumeAsync(user);
        Assert.Equal(12_000m, volume.TotalVolumeKg);
        Assert.Equal(march, Milestone(volume, "grand-piano").ReachedAt);
        Assert.Equal(april, Milestone(volume, "small-car").ReachedAt);
        Assert.Equal(april, Milestone(volume, "elephant").ReachedAt);
        Assert.Equal(summary.CompletedAt, Milestone(volume, "city-bus").ReachedAt);
    }

    [Fact]
    public async Task Viewing_the_volume_back_fills_without_a_workout()
    {
        var user = await api.RegisterUserAsync();
        await AddHistoryAsync(user.Id, await api.AddExerciseAsync(), DateTime.UtcNow.AddDays(-3), 1_500m);

        var volume = await GetVolumeAsync(user);

        Assert.NotNull(Milestone(volume, "small-car").ReachedAt);
        var saved = await api.WithDbContextAsync(context => context.VolumeMilestones.CountAsync(m => m.UserId == user.Id));
        Assert.Equal(2, saved);
    }

    [Fact]
    public async Task The_volume_belongs_to_each_user()
    {
        var owner = await api.RegisterUserAsync();
        var other = await api.RegisterUserAsync();
        await FinishWorkoutAsync(owner, (10, 100m));

        var volume = await GetVolumeAsync(other);

        Assert.Equal(0m, volume.TotalVolumeKg);
        Assert.All(volume.Milestones, m => Assert.Null(m.ReachedAt));
    }

    [Fact]
    public async Task The_volume_needs_a_sign_in()
    {
        var response = await api.CreateClient().GetAsync(Volume);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    private static VolumeMilestoneDto Milestone(VolumeStatsDto volume, string key) =>
        volume.Milestones.Single(m => m.Key == key);

    private static async Task<VolumeStatsDto> GetVolumeAsync(TestUser user) =>
        (await user.Client.GetFromJsonAsync<VolumeStatsDto>(Volume, Json))!;

    private async Task<WorkoutSessionSummaryDto> FinishWorkoutAsync(TestUser user, params (int Reps, decimal? WeightKg)[] sets)
    {
        var session = await StartAsync(user);
        var exercise = await AddExerciseAsync(user, session.Id);
        foreach (var (reps, weightKg) in sets)
        {
            await AddSetAsync(user, session.Id, exercise.Id, reps, weightKg);
        }

        var response = await user.Client.PostAsJsonAsync($"{Sessions}/{session.Id}/complete", new { });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<WorkoutSessionSummaryDto>(Json))!;
    }

    private static async Task<WorkoutSessionResponseDto> StartAsync(TestUser user)
    {
        var response = await user.Client.PostAsJsonAsync(Sessions, new { });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<WorkoutSessionResponseDto>(Json))!;
    }

    private async Task<SessionExerciseResponseDto> AddExerciseAsync(TestUser user, Guid sessionId)
    {
        var exerciseId = await api.AddExerciseAsync();
        var response = await user.Client.PostAsJsonAsync($"{Sessions}/{sessionId}/exercises", new { exerciseId });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<SessionExerciseResponseDto>(Json))!;
    }

    private static async Task AddSetAsync(TestUser user, Guid sessionId, Guid sessionExerciseId, int reps, decimal? weightKg)
    {
        var response = await user.Client.PostAsJsonAsync(
            $"{Sessions}/{sessionId}/exercises/{sessionExerciseId}/sets", new { reps, weightKg });
        response.EnsureSuccessStatusCode();
    }

    // a workout finished in the past, written straight to the database, as sets of 10 × 50 kg
    private Task AddHistoryAsync(Guid userId, string exerciseId, DateTime completedAt, decimal volumeKg) =>
        api.WithDbContextAsync(async context =>
        {
            context.WorkoutSessions.Add(new WorkoutSession
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Name = "Old workout",
                StartedAt = completedAt.AddHours(-1),
                CompletedAt = completedAt,
                Exercises =
                [
                    new SessionExercise
                    {
                        Id = Guid.NewGuid(),
                        ExerciseId = exerciseId,
                        Order = 1,
                        Sets = Enumerable.Range(1, (int)(volumeKg / 500))
                            .Select(n => new SessionSet { Id = Guid.NewGuid(), SetNumber = n, Reps = 10, WeightKg = 50m })
                            .ToList()
                    }
                ]
            });
            await context.SaveChangesAsync();
        });
}
