using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using FitPlan.Api.DTOs.Profile;
using FitPlan.Api.DTOs.WorkoutPlanExercises;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Exercises;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 6: hidden cardio exercises (3.2) and the closed public picture links (F-04).
[Collection(ApiCollection.Name)]
public class ExerciseLibraryTests(ApiFixture api)
{
    // A service with its own catalog, so exercises added by this test are read fresh,
    // not from a list the shared API host loaded earlier.
    private ExerciseService NewService(params string[] hidden)
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(hidden.Select((part, i) =>
                new KeyValuePair<string, string?>($"{ExerciseService.HiddenBodyPartsSetting}:{i}", part)))
            .Build();
        var catalog = new ExerciseCatalog(
            api.Services.GetRequiredService<IServiceScopeFactory>(), TimeProvider.System,
            NullLogger<ExerciseCatalog>.Instance, new ConfigurationBuilder().Build());
        return new ExerciseService(catalog, configuration);
    }

    [Fact]
    public async Task Hidden_exercises_are_left_out_of_the_list_search_and_body_parts()
    {
        var word = "Hidden" + Guid.NewGuid().ToString("N")[..8];
        var cardio = await api.AddExerciseAsync($"{word} jumping jacks", "cardio");
        var chest = await api.AddExerciseAsync($"{word} push-up", "chest");
        var service = NewService("cardio");

        var search = await service.GetAllExercisesAsync(1, 100, null, word);
        var filtered = await service.GetAllExercisesAsync(1, 100, "cardio", word);
        var parts = await service.GetBodyPartsAsync();

        Assert.Equal([chest], search.Items.Select(e => e.Id));
        Assert.Equal(1, search.TotalCount);
        Assert.Empty(filtered.Items);
        Assert.DoesNotContain("cardio", parts);
        Assert.Contains("chest", parts);
        Assert.True((await service.GetExerciseByIdAsync(cardio)).IsSuccess);
    }

    [Fact]
    public async Task Clearing_the_setting_brings_them_back()
    {
        var word = "Shown" + Guid.NewGuid().ToString("N")[..8];
        var cardio = await api.AddExerciseAsync($"{word} rowing", "cardio");
        var service = NewService();

        var search = await service.GetAllExercisesAsync(1, 100, null, word);

        Assert.Equal([cardio], search.Items.Select(e => e.Id));
        Assert.Contains("cardio", await service.GetBodyPartsAsync());
    }

    [Fact]
    public void The_API_hides_cardio_by_default()
    {
        var configuration = api.Services.GetRequiredService<IConfiguration>();

        Assert.Equal(["cardio"], configuration.GetSection(ExerciseService.HiddenBodyPartsSetting).Get<string[]>()!);
    }

    [Fact]
    public async Task A_plan_with_a_hidden_exercise_still_opens()
    {
        var user = await api.RegisterUserAsync();
        var cardio = await api.AddExerciseAsync("Old plan treadmill", "cardio");
        var planId = Guid.NewGuid();
        await api.WithDbContextAsync(async context =>
        {
            context.WorkoutPlans.Add(new WorkoutPlan
            {
                Id = planId,
                Name = "Old plan",
                UserId = user.Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Exercises = [new WorkoutPlanExercise { Id = Guid.NewGuid(), ExerciseId = cardio, Sets = 1, Reps = 10, Order = 10 }]
            });
            await context.SaveChangesAsync();
        });

        var response = await user.Client.GetAsync($"/api/workout-plans/{planId}/exercises");
        var exercises = await response.Content.ReadFromJsonAsync<List<WorkoutPlanExerciseResponseDto>>();
        var byId = await user.Client.GetAsync($"/api/exercises/{cardio}");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal(cardio, Assert.Single(exercises!).ExerciseId);
        Assert.Equal(HttpStatusCode.OK, byId.StatusCode);
    }

    [Fact]
    public async Task A_picture_is_no_longer_a_public_file()
    {
        var user = await api.RegisterUserAsync();
        byte[] png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0x0D, 0x49, 0x48, 0x44, 0x52];
        var content = new ByteArrayContent(png);
        content.Headers.ContentType = new MediaTypeHeaderValue("image/png");
        var upload = await user.Client.PostAsync("/api/profile/me/picture", new MultipartFormDataContent { { content, "file", "me.png" } });
        upload.EnsureSuccessStatusCode();
        var url = (await upload.Content.ReadFromJsonAsync<ProfileDto>())!.ProfilePictureUrl!;

        var anonymous = await api.CreateClient().GetAsync(url);
        var signedIn = await user.Client.GetAsync(url);

        Assert.StartsWith("/uploads/", url);
        Assert.Equal(HttpStatusCode.NotFound, anonymous.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, signedIn.StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await user.Client.GetAsync("/api/profile/me/picture")).StatusCode);
    }
}
