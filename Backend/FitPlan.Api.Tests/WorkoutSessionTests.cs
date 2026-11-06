using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using FitPlan.Api.DTOs.Common;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Models;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

[Collection(ApiCollection.Name)]
public class WorkoutSessionTests(ApiFixture api)
{
    private const string Sessions = "/api/sessions";

    // Same as Program.cs: enums travel as text in the JSON.
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() }
    };

    [Fact]
    public async Task Start_creates_an_empty_quick_workout_that_can_be_resumed()
    {
        var user = await api.RegisterUserAsync();

        var started = await user.Client.PostAsJsonAsync(Sessions, new { });

        Assert.Equal(HttpStatusCode.Created, started.StatusCode);
        var session = await ReadSessionAsync(started);
        Assert.Equal("Quick Workout", session.Name);
        Assert.Null(session.CompletedAt);
        Assert.Empty(session.Exercises);

        var active = await user.Client.GetFromJsonAsync<WorkoutSessionResponseDto>($"{Sessions}/active", Json);
        Assert.Equal(session.Id, active!.Id);
    }

    [Fact]
    public async Task Active_returns_not_found_when_nothing_is_in_progress()
    {
        var user = await api.RegisterUserAsync();

        var response = await user.Client.GetAsync($"{Sessions}/active");

        await response.AssertProblemAsync(HttpStatusCode.NotFound, "NoActiveSession");
    }

    [Fact]
    public async Task Start_is_refused_while_another_session_is_in_progress()
    {
        var user = await api.RegisterUserAsync();
        await StartAsync(user);

        var second = await user.Client.PostAsJsonAsync(Sessions, new { });

        await second.AssertProblemAsync(HttpStatusCode.Conflict, "ActiveSessionExists");
    }

    [Fact]
    public async Task Two_starts_at_the_same_moment_create_only_one_session()
    {
        var user = await api.RegisterUserAsync();

        var responses = await Task.WhenAll(
            user.Client.PostAsJsonAsync(Sessions, new { }),
            user.Client.PostAsJsonAsync(Sessions, new { }));

        Assert.Single(responses, r => r.StatusCode == HttpStatusCode.Created);
        Assert.Single(responses, r => r.StatusCode == HttpStatusCode.Conflict);

        var active = await api.WithDbContextAsync(context =>
            context.WorkoutSessions.CountAsync(s => s.UserId == user.Id && s.CompletedAt == null));
        Assert.Equal(1, active);
    }

    [Fact]
    public async Task Start_from_a_plan_copies_its_exercises_in_order()
    {
        var user = await api.RegisterUserAsync();
        var first = await api.AddExerciseAsync("First");
        var second = await api.AddExerciseAsync("Second");
        var planId = await AddPlanAsync(user.Id, (second, 20), (first, 10));

        var started = await user.Client.PostAsJsonAsync(Sessions, new { workoutPlanId = planId });

        Assert.Equal(HttpStatusCode.Created, started.StatusCode);
        var session = await ReadSessionAsync(started);
        Assert.Equal(planId, session.WorkoutPlanId);
        Assert.Equal([first, second], session.Exercises.OrderBy(e => e.Order).Select(e => e.ExerciseId));
        Assert.Equal([1, 2], session.Exercises.Select(e => e.Order).Order());
    }

    [Fact]
    public async Task Start_from_another_users_plan_is_refused()
    {
        var owner = await api.RegisterUserAsync();
        var other = await api.RegisterUserAsync();
        var planId = await AddPlanAsync(owner.Id, (await api.AddExerciseAsync(), 10));

        var response = await other.Client.PostAsJsonAsync(Sessions, new { workoutPlanId = planId });

        await response.AssertProblemAsync(HttpStatusCode.NotFound, "WorkoutPlanNotFound");
    }

    [Fact]
    public async Task Another_user_cannot_read_change_finish_or_delete_a_session()
    {
        var owner = await api.RegisterUserAsync();
        var other = await api.RegisterUserAsync();
        var session = await StartAsync(owner);
        var exerciseId = await api.AddExerciseAsync();

        var read = await other.Client.GetAsync($"{Sessions}/{session.Id}");
        var addExercise = await other.Client.PostAsJsonAsync($"{Sessions}/{session.Id}/exercises", new { exerciseId });
        var complete = await other.Client.PostAsJsonAsync($"{Sessions}/{session.Id}/complete", new { });
        var delete = await other.Client.DeleteAsync($"{Sessions}/{session.Id}");

        await read.AssertProblemAsync(HttpStatusCode.NotFound, "WorkoutSessionNotFound");
        await addExercise.AssertProblemAsync(HttpStatusCode.NotFound, "WorkoutSessionNotFound");
        await complete.AssertProblemAsync(HttpStatusCode.NotFound, "WorkoutSessionNotFound");
        await delete.AssertProblemAsync(HttpStatusCode.NotFound, "WorkoutSessionNotFound");

        var stillThere = await owner.Client.GetAsync($"{Sessions}/{session.Id}");
        Assert.Equal(HttpStatusCode.OK, stillThere.StatusCode);
    }

    [Fact]
    public async Task Complete_is_refused_when_nothing_was_logged()
    {
        var user = await api.RegisterUserAsync();
        var session = await StartAsync(user);

        var response = await user.Client.PostAsJsonAsync($"{Sessions}/{session.Id}/complete", new { });

        await response.AssertProblemAsync(HttpStatusCode.BadRequest, "EmptySession");
    }

    [Fact]
    public async Task Complete_returns_the_totals_and_drops_skipped_exercises()
    {
        var user = await api.RegisterUserAsync();
        var done = await api.AddExerciseAsync("Done");
        var skipped = await api.AddExerciseAsync("Skipped");
        var planId = await AddPlanAsync(user.Id, (done, 10), (skipped, 20));
        var started = await user.Client.PostAsJsonAsync(Sessions, new { workoutPlanId = planId });
        var session = await ReadSessionAsync(started);
        var doneInSession = session.Exercises.Single(e => e.ExerciseId == done);

        await AddSetAsync(user, session.Id, doneInSession.Id, reps: 10, weightKg: 50m);
        await AddSetAsync(user, session.Id, doneInSession.Id, reps: 8, weightKg: 60m);

        var response = await user.Client.PostAsJsonAsync($"{Sessions}/{session.Id}/complete", new { notes = "Felt good" });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var summary = await response.Content.ReadFromJsonAsync<WorkoutSessionSummaryDto>(Json);
        Assert.Equal(1, summary!.ExerciseCount);
        Assert.Equal(2, summary.SetCount);
        Assert.Equal(980m, summary.TotalVolumeKg);

        var saved = await user.Client.GetFromJsonAsync<WorkoutSessionResponseDto>($"{Sessions}/{session.Id}", Json);
        Assert.Equal("Felt good", saved!.Notes);
        Assert.Equal(done, Assert.Single(saved.Exercises).ExerciseId);
    }

    [Fact]
    public async Task A_completed_session_can_not_be_finished_or_changed_again()
    {
        var user = await api.RegisterUserAsync();
        var (session, exercise) = await CompleteOneSetSessionAsync(user);

        var finishAgain = await user.Client.PostAsJsonAsync($"{Sessions}/{session.Id}/complete", new { });
        var addSet = await user.Client.PostAsJsonAsync(
            $"{Sessions}/{session.Id}/exercises/{exercise.Id}/sets", new { reps = 5, weightKg = 20m });

        await finishAgain.AssertProblemAsync(HttpStatusCode.Conflict, "SessionNotActive");
        await addSet.AssertProblemAsync(HttpStatusCode.Conflict, "SessionNotActive");
    }

    [Theory]
    [InlineData(0, 50)]
    [InlineData(101, 50)]
    [InlineData(10, -1)]
    [InlineData(10, 501)]
    public async Task A_set_outside_the_allowed_range_is_refused(int reps, decimal weightKg)
    {
        var user = await api.RegisterUserAsync();
        var session = await StartAsync(user);
        var exercise = await AddExerciseToSessionAsync(user, session.Id, await api.AddExerciseAsync());

        var response = await user.Client.PostAsJsonAsync(
            $"{Sessions}/{session.Id}/exercises/{exercise.Id}/sets", new { reps, weightKg });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task An_exercise_stops_accepting_sets_after_ten()
    {
        var user = await api.RegisterUserAsync();
        var session = await StartAsync(user);
        var exercise = await AddExerciseToSessionAsync(user, session.Id, await api.AddExerciseAsync());

        for (var i = 0; i < 10; i++)
        {
            await AddSetAsync(user, session.Id, exercise.Id, reps: 5, weightKg: 20m);
        }

        var eleventh = await user.Client.PostAsJsonAsync(
            $"{Sessions}/{session.Id}/exercises/{exercise.Id}/sets", new { reps = 5, weightKg = 20m });

        await eleventh.AssertProblemAsync(HttpStatusCode.BadRequest, "SetLimitReached");
    }

    [Fact]
    public async Task History_lists_only_completed_sessions_of_the_user_newest_first()
    {
        var user = await api.RegisterUserAsync();
        var other = await api.RegisterUserAsync();
        await CompleteOneSetSessionAsync(other);
        var (older, _) = await CompleteOneSetSessionAsync(user);
        var (newer, _) = await CompleteOneSetSessionAsync(user);
        await StartAsync(user);

        var history = await user.Client.GetFromJsonAsync<PagedResponseDto<WorkoutSessionSummaryDto>>(Sessions, Json);

        Assert.Equal(2, history!.TotalCount);
        Assert.Equal([newer.Id, older.Id], history.Items.Select(s => s.Id));
    }

    [Fact]
    public async Task The_next_session_shows_what_was_done_last_time()
    {
        var user = await api.RegisterUserAsync();
        var exerciseId = await api.AddExerciseAsync();

        var first = await StartAsync(user);
        var firstExercise = await AddExerciseToSessionAsync(user, first.Id, exerciseId);
        await AddSetAsync(user, first.Id, firstExercise.Id, reps: 10, weightKg: 50m);
        (await user.Client.PostAsJsonAsync($"{Sessions}/{first.Id}/complete", new { })).EnsureSuccessStatusCode();

        var second = await StartAsync(user);
        var secondExercise = await AddExerciseToSessionAsync(user, second.Id, exerciseId);

        var lastSet = Assert.Single(secondExercise.LastPerformance!.Sets);
        Assert.Equal(10, lastSet.Reps);
        Assert.Equal(50m, lastSet.WeightKg);
        Assert.NotNull(secondExercise.Suggestion);
    }

    [Fact]
    public async Task Deleting_a_session_removes_its_sets_and_allows_a_new_start()
    {
        var user = await api.RegisterUserAsync();
        var session = await StartAsync(user);
        var exercise = await AddExerciseToSessionAsync(user, session.Id, await api.AddExerciseAsync());
        await AddSetAsync(user, session.Id, exercise.Id, reps: 5, weightKg: 20m);

        var deleted = await user.Client.DeleteAsync($"{Sessions}/{session.Id}");

        Assert.Equal(HttpStatusCode.NoContent, deleted.StatusCode);
        var remainingSets = await api.WithDbContextAsync(context =>
            context.SessionSets.CountAsync(s => s.SessionExerciseId == exercise.Id));
        Assert.Equal(0, remainingSets);

        var restarted = await user.Client.PostAsJsonAsync(Sessions, new { });
        Assert.Equal(HttpStatusCode.Created, restarted.StatusCode);
    }

    private static async Task<WorkoutSessionResponseDto> ReadSessionAsync(HttpResponseMessage response) =>
        (await response.Content.ReadFromJsonAsync<WorkoutSessionResponseDto>(Json))!;

    private static async Task<WorkoutSessionResponseDto> StartAsync(TestUser user)
    {
        var response = await user.Client.PostAsJsonAsync(Sessions, new { });
        response.EnsureSuccessStatusCode();
        return await ReadSessionAsync(response);
    }

    private static async Task<SessionExerciseResponseDto> AddExerciseToSessionAsync(TestUser user, Guid sessionId, string exerciseId)
    {
        var response = await user.Client.PostAsJsonAsync($"{Sessions}/{sessionId}/exercises", new { exerciseId });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<SessionExerciseResponseDto>(Json))!;
    }

    private static async Task AddSetAsync(TestUser user, Guid sessionId, Guid sessionExerciseId, int reps, decimal weightKg)
    {
        var response = await user.Client.PostAsJsonAsync(
            $"{Sessions}/{sessionId}/exercises/{sessionExerciseId}/sets", new { reps, weightKg });
        response.EnsureSuccessStatusCode();
    }

    private async Task<(WorkoutSessionResponseDto Session, SessionExerciseResponseDto Exercise)> CompleteOneSetSessionAsync(TestUser user)
    {
        var session = await StartAsync(user);
        var exercise = await AddExerciseToSessionAsync(user, session.Id, await api.AddExerciseAsync());
        await AddSetAsync(user, session.Id, exercise.Id, reps: 5, weightKg: 20m);
        (await user.Client.PostAsJsonAsync($"{Sessions}/{session.Id}/complete", new { })).EnsureSuccessStatusCode();
        return (session, exercise);
    }

    private async Task<Guid> AddPlanAsync(Guid userId, params (string ExerciseId, int Order)[] exercises)
    {
        var planId = Guid.NewGuid();

        await api.WithDbContextAsync(async context =>
        {
            context.WorkoutPlans.Add(new WorkoutPlan
            {
                Id = planId,
                Name = "Test plan",
                UserId = userId,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Exercises = exercises.Select(e => new WorkoutPlanExercise
                {
                    Id = Guid.NewGuid(),
                    ExerciseId = e.ExerciseId,
                    Sets = 3,
                    Reps = 10,
                    Order = e.Order
                }).ToList()
            });
            await context.SaveChangesAsync();
        });

        return planId;
    }
}
