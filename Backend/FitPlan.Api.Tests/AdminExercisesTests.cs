using System.Net;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.Services.Exercises;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 12C: exercises and their GIF links.
[Collection(ApiCollection.Name)]
public class AdminExercisesTests(ApiFixture api)
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web) { Converters = { new JsonStringEnumConverter() } };

    private static object Text(string english, string arabic) => new
    {
        englishName = english,
        englishInstructions = new[] { "Lie on the bench.", "Press up." },
        arabicName = arabic,
        arabicInstructions = new[] { "استلقِ على المقعد.", "ادفع للأعلى." }
    };

    [Fact]
    public async Task Exercise_routes_refuse_a_normal_user()
    {
        var user = await api.RegisterUserAsync();
        var id = await api.AddExerciseAsync();

        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.GetAsync("/api/admin/exercises")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.PutAsJsonAsync($"/api/admin/exercises/{id}/text", Text("A b", "أ ب"))).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.PostAsync($"/api/admin/exercises/{id}/hide", null)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.PostAsync($"/api/admin/exercises/{id}/check-gif", null)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.PostAsJsonAsync("/api/admin/exercises/check-gifs", new { offset = 0, count = 1 })).StatusCode);
    }

    [Fact]
    public async Task Saving_text_changes_the_library_in_both_languages_at_once()
    {
        var (owner, admin) = await api.SignInAsOwnerAsync();
        var id = await api.AddExerciseAsync();
        await api.CreateClient().GetAsync($"/api/exercises/{id}"); // the library has loaded the old text
        var english = "Pin press " + Guid.NewGuid().ToString("N")[..6];

        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync($"/api/admin/exercises/{id}/text", Text(english, "ضغط من المساند"))).StatusCode);

        var shownEnglish = await api.CreateClient().GetStringAsync($"/api/exercises/{id}");
        var arabicClient = api.CreateClient();
        arabicClient.DefaultRequestHeaders.Add("Accept-Language", "ar");
        var shownArabic = await arabicClient.GetStringAsync($"/api/exercises/{id}");
        Assert.Contains(english, shownEnglish);
        Assert.Contains("ضغط من المساند", shownArabic);
        Assert.True(await api.WithDbContextAsync(c => c.ExerciseTranslations.AnyAsync(t => t.ExerciseId == id && t.Reviewed)));
        Assert.True(await api.WithDbContextAsync(c => c.AdminAuditEntries.AnyAsync(e => e.AdminUserId == owner.Id && e.Action == "Edited exercise text")));
    }

    [Fact]
    public async Task Text_without_both_languages_is_refused()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var id = await api.AddExerciseAsync();

        var blankArabicSteps = await admin.PutAsJsonAsync($"/api/admin/exercises/{id}/text", new
        {
            englishName = "Press", englishInstructions = new[] { "Push" }, arabicName = "ضغط", arabicInstructions = new[] { "  " }
        });
        var noArabic = await admin.PutAsJsonAsync($"/api/admin/exercises/{id}/text", new { englishName = "Press", englishInstructions = new[] { "Push" } });

        await blankArabicSteps.AssertProblemAsync(HttpStatusCode.BadRequest, "ExerciseTextIncomplete");
        Assert.Equal(HttpStatusCode.BadRequest, noArabic.StatusCode);
    }

    [Fact]
    public async Task Hiding_leaves_it_out_of_the_library_but_it_still_loads_by_id()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var name = "Hidden lift " + Guid.NewGuid().ToString("N")[..6];
        var id = await api.AddExerciseAsync(name);

        Assert.Equal(HttpStatusCode.NoContent, (await admin.PostAsync($"/api/admin/exercises/{id}/hide", null)).StatusCode);

        Assert.DoesNotContain(id, await api.CreateClient().GetStringAsync($"/api/exercises?search={Uri.EscapeDataString(name)}"));
        Assert.Equal(HttpStatusCode.OK, (await api.CreateClient().GetAsync($"/api/exercises/{id}")).StatusCode);

        await admin.PostAsync($"/api/admin/exercises/{id}/show", null);
        Assert.Contains(id, await api.CreateClient().GetStringAsync($"/api/exercises?search={Uri.EscapeDataString(name)}"));
    }

    [Fact]
    public async Task A_link_check_batch_saves_each_status()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var id = await api.AddExerciseAsync();
        // nothing listens on port 1, so the link can't be reached
        await api.WithDbContextAsync(c => c.Exercises.Where(e => e.Id == id).ExecuteUpdateAsync(s => s.SetProperty(e => e.GifUrl, "http://127.0.0.1:1/a.gif")));
        var offset = await api.WithDbContextAsync(c => c.Exercises.CountAsync(e => string.Compare(e.Id, id) < 0));

        var result = await (await admin.PostAsJsonAsync("/api/admin/exercises/check-gifs", new { offset, count = 1 }))
            .Content.ReadFromJsonAsync<AdminGifCheckResultDto>(Json);

        Assert.Equal(1, result!.Checked);
        Assert.Equal(offset + 1, result.NextOffset);
        Assert.Equal(GifStatus.Unreachable, await api.WithDbContextAsync(c => c.Exercises.Where(e => e.Id == id).Select(e => e.GifStatus).SingleAsync()));
    }

    [Theory]
    [InlineData(HttpStatusCode.NotFound, "", GifStatus.Missing)]
    [InlineData(HttpStatusCode.OK, "GIF89a....", GifStatus.Works)]
    [InlineData(HttpStatusCode.OK, "<html>", GifStatus.NotAGif)]
    public async Task A_link_is_judged_by_its_answer(HttpStatusCode status, string body, GifStatus expected)
    {
        using var client = new HttpClient(new Answer(status, body));

        var (result, _) = await GifLink.CheckAsync(client, "https://media.example.test/a.gif");

        Assert.Equal(expected, result);
    }

    private sealed class Answer(HttpStatusCode status, string body) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken) =>
            Task.FromResult(new HttpResponseMessage(status) { Content = new ByteArrayContent(Encoding.ASCII.GetBytes(body)) });
    }
}
