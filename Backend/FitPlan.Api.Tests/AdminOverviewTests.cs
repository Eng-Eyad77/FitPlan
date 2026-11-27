using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.Tests.Infrastructure;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 12E: the overview figures. Other tests share the database, so these compare before and after.
[Collection(ApiCollection.Name)]
public class AdminOverviewTests(ApiFixture api)
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    [Fact]
    public async Task A_normal_user_cant_see_the_overview()
    {
        var user = await api.RegisterUserAsync();

        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.GetAsync("/api/admin/overview")).StatusCode);
    }

    [Fact]
    public async Task A_finished_workout_counts_in_every_figure_and_names_no_user()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var before = await OverviewAsync(admin, refresh: true);
        var user = await api.RegisterUserAsync();
        var exerciseName = "Overview press " + Guid.NewGuid().ToString("N")[..6];
        await FinishedWorkoutAsync(user, await api.AddExerciseAsync(exerciseName));

        var body = await (await admin.GetAsync("/api/admin/overview?refresh=true")).Content.ReadAsStringAsync();
        var after = JsonSerializer.Deserialize<AdminOverviewDto>(body, Json)!;

        Assert.Equal(before.Users + 1, after.Users);
        Assert.Equal(before.NewUsersLast7Days + 1, after.NewUsersLast7Days);
        Assert.Equal(before.ActiveUsersLast7Days + 1, after.ActiveUsersLast7Days);
        Assert.Equal(before.WorkoutsLast7Days + 1, after.WorkoutsLast7Days);
        Assert.Equal(before.WorkoutsPerDay[^1] + 1, after.WorkoutsPerDay[^1]);
        Assert.Equal(14, after.WorkoutsPerDay.Count);
        Assert.Equal(before.SignUpsPerWeek[^1] + 1, after.SignUpsPerWeek[^1]);
        Assert.Equal(8, after.SignUpsPerWeek.Count);
        Assert.Equal(before.VolumeKgLast7Days + 2 * 5 * 40m, after.VolumeKgLast7Days);
        Assert.Equal(before.CardioEntriesThisMonth + 1, after.CardioEntriesThisMonth);
        Assert.DoesNotContain(user.Username, body);
        Assert.DoesNotContain(user.Email, body);
    }

    [Fact]
    public async Task The_figures_are_kept_until_refreshed()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var counted = await OverviewAsync(admin, refresh: true);
        await api.RegisterUserAsync();

        var kept = await OverviewAsync(admin, refresh: false);
        var fresh = await OverviewAsync(admin, refresh: true);

        Assert.Equal(counted.CountedAt, kept.CountedAt);
        Assert.Equal(counted.Users, kept.Users);
        Assert.True(fresh.Users > counted.Users);
    }

    private static async Task<AdminOverviewDto> OverviewAsync(HttpClient admin, bool refresh) =>
        (await admin.GetFromJsonAsync<AdminOverviewDto>($"/api/admin/overview?refresh={refresh}", Json))!;

    // two sets of 5 × 40 kg and one cardio entry
    private static async Task FinishedWorkoutAsync(TestUser user, string exerciseId)
    {
        var start = await user.Client.PostAsJsonAsync("/api/sessions", new { });
        start.EnsureSuccessStatusCode();
        var sessionId = Id(await start.Content.ReadAsStringAsync());
        var added = await user.Client.PostAsJsonAsync($"/api/sessions/{sessionId}/exercises", new { exerciseId });
        added.EnsureSuccessStatusCode();
        var sessionExerciseId = Id(await added.Content.ReadAsStringAsync());
        for (var i = 0; i < 2; i++)
        {
            (await user.Client.PostAsJsonAsync($"/api/sessions/{sessionId}/exercises/{sessionExerciseId}/sets",
                new { reps = 5, weightKg = 40m })).EnsureSuccessStatusCode();
        }

        (await user.Client.PostAsJsonAsync($"/api/sessions/{sessionId}/cardio", new { machine = "Rower", durationSeconds = 600 })).EnsureSuccessStatusCode();
        (await user.Client.PostAsJsonAsync($"/api/sessions/{sessionId}/complete", new { })).EnsureSuccessStatusCode();
    }

    private static Guid Id(string json) => JsonDocument.Parse(json).RootElement.GetProperty("id").GetGuid();
}
