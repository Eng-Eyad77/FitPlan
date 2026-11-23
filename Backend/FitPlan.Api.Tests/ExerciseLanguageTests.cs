using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using FitPlan.Api.DTOs.Exercises;
using FitPlan.Api.DTOs.WorkoutPlanExercises;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Exercises;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.AspNetCore.Http;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 11C: exercise text in the app's language, with English as the fallback.
[Collection(ApiCollection.Name)]
public class ExerciseLanguageTests(ApiFixture api)
{
    private async Task<string> AddTranslatedAsync(string english, string? arabic, params string[] equipments)
    {
        var id = "lang-" + Guid.NewGuid().ToString("N");
        await api.WithDbContextAsync(async context =>
        {
            context.Exercises.Add(new Exercise
            {
                Id = id,
                Name = english,
                GifUrl = "https://example.test/exercise.gif",
                BodyPart = "chest",
                Instructions = ["Lie down", "Press up"],
                Equipments = [.. equipments],
                TargetMuscles = ["pectorals"],
                SecondaryMuscles = ["triceps", "lang-unknown-muscle"]
            });
            if (arabic is not null)
            {
                context.ExerciseTranslations.Add(new ExerciseTranslation
                {
                    ExerciseId = id,
                    Language = "ar",
                    Name = arabic,
                    Instructions = ["انسدح", "ادفع لفوق"]
                });
            }

            await context.SaveChangesAsync();
        });

        return id;
    }

    // terms are shared by every exercise, so each is added once for the whole run
    private async Task AddTermsAsync()
    {
        await api.WithDbContextAsync(async context =>
        {
            foreach (var (kind, term, text) in new[] { ("equipment", "barbell", "بار"), ("muscle", "pectorals", "الصدر"), ("muscle", "triceps", "الترايسبس") })
            {
                if (await context.TermTranslations.FindAsync(kind, term, "ar") is null)
                {
                    context.TermTranslations.Add(new TermTranslation { Kind = kind, Term = term, Language = "ar", Text = text });
                }
            }

            await context.SaveChangesAsync();
        });
    }

    private static HttpClient InLanguage(HttpClient client, string language)
    {
        client.DefaultRequestHeaders.AcceptLanguage.Clear();
        client.DefaultRequestHeaders.AcceptLanguage.Add(new StringWithQualityHeaderValue(language));
        return client;
    }

    [Fact]
    public async Task An_exercise_comes_in_Arabic_with_its_English_name_and_details()
    {
        await AddTermsAsync();
        var id = await AddTranslatedAsync("Lang bench press", "بنش بريس بار", "barbell");
        await using var host = api.NewHost();

        var response = await InLanguage(host.CreateClient(), "ar-SA").GetAsync($"/api/exercises/{id}");
        var exercise = await response.Content.ReadFromJsonAsync<ExerciseDto>();

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("بنش بريس بار", exercise!.Name);
        Assert.Equal("Lang bench press", exercise.EnglishName);
        Assert.Equal(["انسدح", "ادفع لفوق"], exercise.Instructions);
        Assert.Equal(["بار"], exercise.Equipments);
        Assert.Equal(["الصدر"], exercise.TargetMuscles);
        // a term with no Arabic word stays in English
        Assert.Equal(["الترايسبس", "lang-unknown-muscle"], exercise.SecondaryMuscles);
        Assert.Equal("chest", exercise.BodyPart);
        Assert.Contains("Accept-Language", response.Headers.Vary);
    }

    [Fact]
    public async Task English_is_unchanged()
    {
        await AddTermsAsync();
        var id = await AddTranslatedAsync("Lang english press", "ضغط", "barbell");
        await using var host = api.NewHost();

        foreach (var client in new[] { host.CreateClient(), InLanguage(host.CreateClient(), "en-US"), InLanguage(host.CreateClient(), "fr") })
        {
            var exercise = await client.GetFromJsonAsync<ExerciseDto>($"/api/exercises/{id}");

            Assert.Equal("Lang english press", exercise!.Name);
            Assert.Null(exercise.EnglishName);
            Assert.Equal(["Lie down", "Press up"], exercise.Instructions);
            Assert.Equal(["barbell"], exercise.Equipments);
        }
    }

    [Fact]
    public async Task An_exercise_without_Arabic_text_falls_back_to_English()
    {
        var id = await AddTranslatedAsync("Lang untranslated row", arabic: null);
        await using var host = api.NewHost();

        var exercise = await InLanguage(host.CreateClient(), "ar").GetFromJsonAsync<ExerciseDto>($"/api/exercises/{id}");

        Assert.Equal("Lang untranslated row", exercise!.Name);
        Assert.Null(exercise.EnglishName);
        Assert.Equal(["Lie down", "Press up"], exercise.Instructions);
    }

    [Theory]
    [InlineData("ارنولد")]          // أ typed as ا
    [InlineData("أرنولد")]
    [InlineData("بالكرسي")]          // ي for ى is the same letter here, and no diacritics needed
    [InlineData("عضله")]             // ة typed as ه
    [InlineData("lang arnold")]      // the English name still matches
    public async Task Arabic_search_accepts_common_spelling_variants(string search)
    {
        var word = Guid.NewGuid().ToString("N")[..6];
        var id = await AddTranslatedAsync($"Lang arnold press {word}", $"أرنولد برِس بالكرسي عضلة {word}");
        await using var host = api.NewHost();

        var page = await InLanguage(host.CreateClient(), "ar").GetFromJsonAsync<ExerciseListResponseDto>(
            $"/api/exercises?pageSize=100&search={Uri.EscapeDataString(search)}");
        var found = page!.Items.Where(e => e.Id == id).ToList();

        Assert.Single(found);
        Assert.Equal($"أرنولد برِس بالكرسي عضلة {word}", found[0].Name);
    }

    [Fact]
    public async Task A_plan_shows_its_exercises_in_Arabic()
    {
        var user = await api.RegisterUserAsync();
        var id = await AddTranslatedAsync("Lang plan fly", "تفتيح صدر مستوي دمبل");
        var planId = Guid.NewGuid();
        await api.WithDbContextAsync(async context =>
        {
            context.WorkoutPlans.Add(new WorkoutPlan
            {
                Id = planId,
                Name = "Lang plan",
                UserId = user.Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Exercises = [new WorkoutPlanExercise { Id = Guid.NewGuid(), ExerciseId = id, Sets = 3, Reps = 10, Order = 1 }]
            });
            await context.SaveChangesAsync();
        });
        await using var host = api.NewHost();
        var client = host.CreateClient();
        client.DefaultRequestHeaders.Authorization = user.Client.DefaultRequestHeaders.Authorization;

        var arabic = await InLanguage(client, "ar").GetFromJsonAsync<List<WorkoutPlanExerciseResponseDto>>($"/api/workout-plans/{planId}/exercises");
        var english = await InLanguage(client, "en").GetFromJsonAsync<List<WorkoutPlanExerciseResponseDto>>($"/api/workout-plans/{planId}/exercises");

        var item = Assert.Single(arabic!);
        Assert.Equal(("تفتيح صدر مستوي دمبل", "Lang plan fly"), (item.Name, item.EnglishName));
        Assert.Equal(["انسدح", "ادفع لفوق"], item.Instructions);
        Assert.Equal(("Lang plan fly", null), (Assert.Single(english!).Name, english![0].EnglishName));
    }

    [Theory]
    [InlineData("أإآٱ", "اااا")]
    [InlineData("عضلة", "عضله")]
    [InlineData("مستوى", "مستوي")]
    [InlineData("شْرَق", "شرق")]
    [InlineData("بنـــش", "بنش")]
    [InlineData("بار EZ", "بار ez")]
    public void Arabic_text_is_normalized_for_search(string text, string expected)
    {
        Assert.Equal(expected, ArabicText.Normalize(text));
    }

    [Theory]
    [InlineData("ar-SA,en;q=0.5", "ar")]
    [InlineData("en-US,ar;q=0.9", "en")]
    [InlineData("en;q=0.1, ar;q=0.9", "ar")]
    [InlineData("fr-FR", "en")]
    [InlineData("", "en")]
    public void The_language_comes_from_Accept_Language(string header, string expected)
    {
        var context = new DefaultHttpContext();
        context.Request.Headers.AcceptLanguage = header;

        Assert.Equal(expected, ContentLanguage.From(context.Request));
    }
}
