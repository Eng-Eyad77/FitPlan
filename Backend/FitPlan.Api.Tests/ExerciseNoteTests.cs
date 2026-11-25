using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using FitPlan.Api.DTOs.WorkoutPlanExercises;
using FitPlan.Api.DTOs.WorkoutPlans;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Tests.Infrastructure;
using Xunit;

namespace FitPlan.Api.Tests;

// A note per plan exercise ("seat on 4"): set in the plan, shown and changeable in a workout, and a
// change made in the workout goes back to the plan when it is completed.
[Collection(ApiCollection.Name)]
public class ExerciseNoteTests(ApiFixture api)
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() }
    };

    [Fact]
    public async Task A_plan_note_is_saved_trimmed_kept_by_other_changes_and_cleared_when_empty()
    {
        var user = await api.RegisterUserAsync();
        var (planId, planExercise) = await PlanWithOneExerciseAsync(user);

        (await SetPlanNoteAsync(user, planId, planExercise.Id, "  seat on 4 ")).EnsureSuccessStatusCode();
        // changing sets, reps and order doesn't touch the note
        (await user.Client.PutAsJsonAsync($"/api/workout-plans/{planId}/exercises/{planExercise.Id}",
            new { sets = 4, reps = 8, order = 1, restSeconds = (int?)null })).EnsureSuccessStatusCode();
        Assert.Equal("seat on 4", (await PlanExercisesAsync(user, planId)).Single().Note);

        (await SetPlanNoteAsync(user, planId, planExercise.Id, "   ")).EnsureSuccessStatusCode();
        Assert.Null((await PlanExercisesAsync(user, planId)).Single().Note);
    }

    [Fact]
    public async Task A_note_over_500_characters_or_on_someone_elses_plan_is_refused()
    {
        var user = await api.RegisterUserAsync();
        var other = await api.RegisterUserAsync();
        var (planId, planExercise) = await PlanWithOneExerciseAsync(user);

        await (await SetPlanNoteAsync(user, planId, planExercise.Id, new string('x', 501)))
            .AssertProblemAsync(HttpStatusCode.BadRequest, "ValidationFailed");
        await (await SetPlanNoteAsync(other, planId, planExercise.Id, "mine"))
            .AssertProblemAsync(HttpStatusCode.NotFound, "WorkoutPlanNotFound");
    }

    [Fact]
    public async Task A_workout_copies_the_note_and_a_change_there_goes_back_to_the_plan()
    {
        var user = await api.RegisterUserAsync();
        var (planId, planExercise) = await PlanWithOneExerciseAsync(user);
        await SetPlanNoteAsync(user, planId, planExercise.Id, "seat on 4");

        var started = await user.Client.PostAsJsonAsync("/api/sessions", new { workoutPlanId = planId });
        var session = (await started.Content.ReadFromJsonAsync<WorkoutSessionResponseDto>(Json))!;
        var exercise = session.Exercises.Single();
        Assert.Equal("seat on 4", exercise.Note);

        (await user.Client.PutAsJsonAsync($"/api/sessions/{session.Id}/exercises/{exercise.Id}/note", new { note = "seat on 5" }))
            .EnsureSuccessStatusCode();
        // not in the plan until the workout is completed
        Assert.Equal("seat on 4", (await PlanExercisesAsync(user, planId)).Single().Note);

        (await user.Client.PostAsJsonAsync($"/api/sessions/{session.Id}/exercises/{exercise.Id}/sets",
            new { reps = 10, weightKg = 40m })).EnsureSuccessStatusCode();
        (await user.Client.PostAsJsonAsync($"/api/sessions/{session.Id}/complete", new { })).EnsureSuccessStatusCode();

        Assert.Equal("seat on 5", (await PlanExercisesAsync(user, planId)).Single().Note);
    }

    private static Task<HttpResponseMessage> SetPlanNoteAsync(TestUser user, Guid planId, Guid id, string note) =>
        user.Client.PutAsJsonAsync($"/api/workout-plans/{planId}/exercises/{id}/note", new { note });

    private static async Task<WorkoutPlanExerciseResponseDto[]> PlanExercisesAsync(TestUser user, Guid planId) =>
        (await user.Client.GetFromJsonAsync<WorkoutPlanExerciseResponseDto[]>($"/api/workout-plans/{planId}/exercises", Json))!;

    private async Task<(Guid PlanId, WorkoutPlanExerciseResponseDto Exercise)> PlanWithOneExerciseAsync(TestUser user)
    {
        var plan = await user.Client.PostAsJsonAsync("/api/workout-plans", new { name = "Note plan" });
        plan.EnsureSuccessStatusCode();
        var planId = (await plan.Content.ReadFromJsonAsync<WorkoutPlanResponseDto>(Json))!.Id;

        var added = await user.Client.PostAsJsonAsync($"/api/workout-plans/{planId}/exercises",
            new { exerciseId = await api.AddExerciseAsync("Leg press"), sets = 3, reps = 10, order = 1 });
        added.EnsureSuccessStatusCode();
        return (planId, (await added.Content.ReadFromJsonAsync<WorkoutPlanExerciseResponseDto>(Json))!);
    }
}
