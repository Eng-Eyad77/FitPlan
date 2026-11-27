using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.DTOs.WorkoutPlans;
using FitPlan.Api.Models;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 12D: a user's plans (read only, logged) and the cardio machines.
[Collection(ApiCollection.Name)]
public class AdminPlansTests(ApiFixture api)
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    [Fact]
    public async Task A_normal_user_cant_view_plans_or_the_cardio_list()
    {
        var user = await api.RegisterUserAsync();

        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.PostAsync($"/api/admin/users/{user.Id}/view-plans", null)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.GetAsync("/api/admin/cardio")).StatusCode);
    }

    [Fact]
    public async Task Viewing_plans_shows_them_in_order_without_notes_and_is_logged()
    {
        var (owner, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();
        var plan = await user.Client.PostAsJsonAsync("/api/workout-plans", new { name = "Push day" });
        var planId = (await plan.Content.ReadFromJsonAsync<WorkoutPlanResponseDto>(Json))!.Id;
        (await user.Client.PostAsJsonAsync($"/api/workout-plans/{planId}/exercises",
            new { exerciseId = await api.AddExerciseAsync("Cable fly"), sets = 3, reps = 12, order = 2, note = "seat on 4" })).EnsureSuccessStatusCode();
        (await user.Client.PostAsJsonAsync($"/api/workout-plans/{planId}/exercises",
            new { exerciseId = await api.AddExerciseAsync("Bench press"), sets = 4, reps = 6, restSeconds = 150, order = 1 })).EnsureSuccessStatusCode();

        var response = await admin.PostAsync($"/api/admin/users/{user.Id}/view-plans", null);
        var body = await response.Content.ReadAsStringAsync();
        var shown = JsonSerializer.Deserialize<AdminUserPlansDto>(body, Json)!;

        Assert.Equal(user.Username, shown.Username);
        var only = Assert.Single(shown.Plans);
        Assert.Equal("Push day", only.Name);
        Assert.Equal(["Bench press", "Cable fly"], only.Exercises.Select(e => e.Name));
        Assert.Equal(150, only.Exercises[0].RestSeconds);
        Assert.DoesNotContain("seat on 4", body);
        Assert.True(await api.WithDbContextAsync(c =>
            c.AdminAuditEntries.AnyAsync(e => e.AdminUserId == owner.Id && e.Action == "Viewed plans" && e.Target == user.Username)));
    }

    [Fact]
    public async Task Plans_of_an_unknown_user_are_not_found()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();

        await (await admin.PostAsync($"/api/admin/users/{Guid.NewGuid()}/view-plans", null))
            .AssertProblemAsync(HttpStatusCode.NotFound, "UserNotFound");
    }

    [Fact]
    public async Task The_cardio_list_has_the_machines_with_their_fields_and_shows_retired_other_only_when_used()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();

        var machines = (await admin.GetFromJsonAsync<AdminCardioMachineDto[]>("/api/admin/cardio", Json))!;

        Assert.Equal(["Treadmill", "StationaryBike", "Elliptical", "StairClimber", "Rower", "Swimming"], machines.Select(m => m.Machine).Where(m => m != "Other"));
        Assert.Equal(["speedKmh", "inclinePercent", "distanceKm"], machines.Single(m => m.Machine == "Treadmill").Fields);
        // other tests share the database and may have saved an old-style Other entry this month
        Assert.All(machines.Where(m => m.Machine == "Other"), m => Assert.True(m.UsesThisMonth > 0));
    }

    [Fact]
    public async Task The_cardio_list_counts_this_months_entries()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var before = await RowerUsesAsync(admin);
        var user = await api.RegisterUserAsync();
        var start = await user.Client.PostAsJsonAsync("/api/sessions", new { });
        start.EnsureSuccessStatusCode();
        var sessionId = JsonDocument.Parse(await start.Content.ReadAsStringAsync()).RootElement.GetProperty("id").GetGuid();
        (await user.Client.PostAsJsonAsync($"/api/sessions/{sessionId}/cardio",
            new { machine = nameof(CardioMachine.Rower), durationSeconds = 600 })).EnsureSuccessStatusCode();

        Assert.Equal(before + 1, await RowerUsesAsync(admin));
    }

    private static async Task<int> RowerUsesAsync(HttpClient admin) =>
        (await admin.GetFromJsonAsync<AdminCardioMachineDto[]>("/api/admin/cardio", Json))!.Single(m => m.Machine == "Rower").UsesThisMonth;
}
