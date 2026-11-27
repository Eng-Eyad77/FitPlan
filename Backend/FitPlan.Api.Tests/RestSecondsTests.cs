using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using FitPlan.Api.DTOs.WorkoutPlanExercises;
using FitPlan.Api.DTOs.WorkoutPlans;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 7 (4.2): rest per exercise, set in the plan and changeable during the session.
[Collection(ApiCollection.Name)]
public class RestSecondsTests(ApiFixture api)
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() }
    };

    [Fact]
    public async Task The_plan_keeps_the_rest_and_a_session_copies_it()
    {
        var user = await api.RegisterUserAsync();
        var planId = await CreatePlanAsync(user);
        var withRest = await AddToPlanAsync(user, planId, await api.AddExerciseAsync("Squat"), order: 1, restSeconds: 150);
        var withoutRest = await AddToPlanAsync(user, planId, await api.AddExerciseAsync("Curl"), order: 2, restSeconds: null);

        Assert.Equal(150, withRest.RestSeconds);
        Assert.Null(withoutRest.RestSeconds);

        var listed = await user.Client.GetFromJsonAsync<WorkoutPlanExerciseResponseDto[]>($"/api/workout-plans/{planId}/exercises", Json);
        Assert.Equal([150, null], listed!.Select(e => e.RestSeconds));

        var started = await user.Client.PostAsJsonAsync("/api/sessions", new { workoutPlanId = planId });
        var session = (await started.Content.ReadFromJsonAsync<WorkoutSessionResponseDto>(Json))!;
        // null stays null, so the app uses its 90 s default
        Assert.Equal([150, null], session.Exercises.OrderBy(e => e.Order).Select(e => e.RestSeconds));
    }

    [Fact]
    public async Task Changing_the_rest_in_the_plan_saves_it_and_can_clear_it()
    {
        var user = await api.RegisterUserAsync();
        var planId = await CreatePlanAsync(user);
        var added = await AddToPlanAsync(user, planId, await api.AddExerciseAsync(), order: 1, restSeconds: null);

        var set = await user.Client.PutAsJsonAsync($"/api/workout-plans/{planId}/exercises/{added.Id}",
            new { sets = 3, reps = 10, order = 1, restSeconds = 45 });
        Assert.Equal(45, (await set.Content.ReadFromJsonAsync<WorkoutPlanExerciseResponseDto>(Json))!.RestSeconds);

        var cleared = await user.Client.PutAsJsonAsync($"/api/workout-plans/{planId}/exercises/{added.Id}",
            new { sets = 3, reps = 10, order = 1, restSeconds = (int?)null });
        Assert.Null((await cleared.Content.ReadFromJsonAsync<WorkoutPlanExerciseResponseDto>(Json))!.RestSeconds);
    }

    [Theory]
    [InlineData(14)]
    [InlineData(601)]
    [InlineData(0)]
    public async Task A_rest_outside_15_to_600_seconds_is_refused(int restSeconds)
    {
        var user = await api.RegisterUserAsync();
        var planId = await CreatePlanAsync(user);
        var exerciseId = await api.AddExerciseAsync();

        var add = await user.Client.PostAsJsonAsync($"/api/workout-plans/{planId}/exercises",
            new { exerciseId, sets = 3, reps = 10, order = 1, restSeconds });
        Assert.Equal(HttpStatusCode.BadRequest, add.StatusCode);

        var session = await StartQuickAsync(user);
        var exercise = await AddToSessionAsync(user, session.Id, exerciseId);
        var patch = await user.Client.PatchAsJsonAsync($"/api/sessions/{session.Id}/exercises/{exercise.Id}", new { restSeconds });
        Assert.Equal(HttpStatusCode.BadRequest, patch.StatusCode);
    }

    [Fact]
    public async Task Changing_the_rest_during_a_session_does_not_change_the_plan()
    {
        var user = await api.RegisterUserAsync();
        var planId = await CreatePlanAsync(user);
        var planExercise = await AddToPlanAsync(user, planId, await api.AddExerciseAsync(), order: 1, restSeconds: 90);
        var started = await user.Client.PostAsJsonAsync("/api/sessions", new { workoutPlanId = planId });
        var session = (await started.Content.ReadFromJsonAsync<WorkoutSessionResponseDto>(Json))!;
        var sessionExercise = session.Exercises.Single();

        var patch = await user.Client.PatchAsJsonAsync(
            $"/api/sessions/{session.Id}/exercises/{sessionExercise.Id}", new { restSeconds = 240 });

        Assert.Equal(HttpStatusCode.NoContent, patch.StatusCode);
        var active = await user.Client.GetFromJsonAsync<WorkoutSessionResponseDto>("/api/sessions/active", Json);
        Assert.Equal(240, active!.Exercises.Single().RestSeconds);
        var planRest = await api.WithDbContextAsync(context =>
            context.WorkoutPlanExercises.Where(e => e.Id == planExercise.Id).Select(e => e.RestSeconds).SingleAsync());
        Assert.Equal(90, planRest);
    }

    [Fact]
    public async Task Another_users_session_and_a_finished_session_cannot_be_changed()
    {
        var owner = await api.RegisterUserAsync();
        var other = await api.RegisterUserAsync();
        var session = await StartQuickAsync(owner);
        var exercise = await AddToSessionAsync(owner, session.Id, await api.AddExerciseAsync());

        var foreign = await other.Client.PatchAsJsonAsync($"/api/sessions/{session.Id}/exercises/{exercise.Id}", new { restSeconds = 60 });
        await foreign.AssertProblemAsync(HttpStatusCode.NotFound, "WorkoutSessionNotFound");

        var unknown = await owner.Client.PatchAsJsonAsync($"/api/sessions/{session.Id}/exercises/{Guid.NewGuid()}", new { restSeconds = 60 });
        await unknown.AssertProblemAsync(HttpStatusCode.NotFound, "SessionExerciseNotFound");

        (await owner.Client.PostAsJsonAsync($"/api/sessions/{session.Id}/exercises/{exercise.Id}/sets", new { reps = 5, weightKg = 20m }))
            .EnsureSuccessStatusCode();
        (await owner.Client.PostAsJsonAsync($"/api/sessions/{session.Id}/complete", new { })).EnsureSuccessStatusCode();

        var finished = await owner.Client.PatchAsJsonAsync($"/api/sessions/{session.Id}/exercises/{exercise.Id}", new { restSeconds = 60 });
        await finished.AssertProblemAsync(HttpStatusCode.Conflict, "SessionNotActive");
    }

    private static async Task<Guid> CreatePlanAsync(TestUser user)
    {
        var response = await user.Client.PostAsJsonAsync("/api/workout-plans", new { name = "Rest plan" });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<WorkoutPlanResponseDto>(Json))!.Id;
    }

    private static async Task<WorkoutPlanExerciseResponseDto> AddToPlanAsync(
        TestUser user, Guid planId, string exerciseId, int order, int? restSeconds)
    {
        var response = await user.Client.PostAsJsonAsync($"/api/workout-plans/{planId}/exercises",
            new { exerciseId, sets = 3, reps = 10, order, restSeconds });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<WorkoutPlanExerciseResponseDto>(Json))!;
    }

    private static async Task<WorkoutSessionResponseDto> StartQuickAsync(TestUser user)
    {
        var response = await user.Client.PostAsJsonAsync("/api/sessions", new { });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<WorkoutSessionResponseDto>(Json))!;
    }

    private static async Task<SessionExerciseResponseDto> AddToSessionAsync(TestUser user, Guid sessionId, string exerciseId)
    {
        var response = await user.Client.PostAsJsonAsync($"/api/sessions/{sessionId}/exercises", new { exerciseId });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<SessionExerciseResponseDto>(Json))!;
    }
}
