using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using FitPlan.Api.Controllers;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 12: replacing an exercise's demo with an uploaded GIF. Storage is faked here; R2 is checked on Dev.
[Collection(ApiCollection.Name)]
public class AdminGifUploadTests(ApiFixture api)
{
    // the smallest valid GIF: one transparent pixel
    private static readonly byte[] Gif = Convert.FromBase64String("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7");

    [Fact]
    public async Task A_normal_user_cant_upload()
    {
        var user = await api.RegisterUserAsync();
        var id = await api.AddExerciseAsync();

        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.PostAsync($"/api/admin/exercises/{id}/gif", Form(Gif))).StatusCode);
    }

    [Fact]
    public async Task An_uploaded_gif_becomes_the_demo_in_the_library_at_once_and_is_logged()
    {
        var (owner, admin) = await api.SignInAsOwnerAsync();
        var id = await api.AddExerciseAsync("Upload press");
        await api.CreateClient().GetAsync($"/api/exercises/{id}"); // the library has loaded the old link

        var response = await admin.PostAsync($"/api/admin/exercises/{id}/gif", Form(Gif));

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var url = JsonDocument.Parse(await response.Content.ReadAsStringAsync()).RootElement.GetProperty("gifUrl").GetString()!;
        Assert.StartsWith($"{FakeGifStorage.BaseUrl}/exercises/{id}/", url);
        Assert.EndsWith(".gif", url);
        Assert.Equal(Gif, api.Gifs.Saved[url[(FakeGifStorage.BaseUrl.Length + 1)..]]);
        Assert.Contains(url, await api.CreateClient().GetStringAsync($"/api/exercises/{id}"));
        Assert.True(await api.WithDbContextAsync(c => c.Exercises.AnyAsync(e => e.Id == id && e.GifStatus == FitPlan.Api.Services.Exercises.GifStatus.Works)));
        Assert.True(await api.WithDbContextAsync(c =>
            c.AdminAuditEntries.AnyAsync(e => e.AdminUserId == owner.Id && e.Action == "Uploaded GIF" && e.Target!.StartsWith(id))));
    }

    [Fact]
    public async Task A_file_that_isnt_a_gif_is_refused_whatever_its_name()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var id = await api.AddExerciseAsync();
        var png = new byte[] { 0x89, (byte)'P', (byte)'N', (byte)'G', 0x0D, 0x0A, 0x1A, 0x0A, 0, 0 };

        await (await admin.PostAsync($"/api/admin/exercises/{id}/gif", Form(png))).AssertProblemAsync(HttpStatusCode.BadRequest, "GifNotValid");
        // no file at all is refused by the framework's own check before it reaches ours
        Assert.Equal(HttpStatusCode.BadRequest, (await admin.PostAsync($"/api/admin/exercises/{id}/gif", new MultipartFormDataContent())).StatusCode);
        Assert.DoesNotContain(api.Gifs.Saved.Keys, k => k.StartsWith($"exercises/{id}/"));
    }

    [Fact]
    public async Task A_gif_over_5_mb_is_refused()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var id = await api.AddExerciseAsync();
        var big = new byte[AdminExercisesController.MaxGifBytes + 1];
        Gif.CopyTo(big, 0);

        await (await admin.PostAsync($"/api/admin/exercises/{id}/gif", Form(big))).AssertProblemAsync(HttpStatusCode.RequestEntityTooLarge, "GifTooLarge");
    }

    [Fact]
    public async Task An_unknown_exercise_or_storage_not_set_up_is_said_plainly()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();

        await (await admin.PostAsync("/api/admin/exercises/no-such-exercise/gif", Form(Gif))).AssertProblemAsync(HttpStatusCode.NotFound, "ExerciseNotFound");

        api.Gifs.Configured = false;
        try
        {
            await (await admin.PostAsync($"/api/admin/exercises/{await api.AddExerciseAsync()}/gif", Form(Gif)))
                .AssertProblemAsync(HttpStatusCode.ServiceUnavailable, "GifUploadNotSetUp");
        }
        finally
        {
            api.Gifs.Configured = true;
        }
    }

    [Fact]
    public void The_storage_key_keeps_only_safe_characters_and_changes_with_the_file()
    {
        var key = AdminExercisesController.GifKey("../ab c/é", Gif);

        Assert.Matches("^exercises/---ab-c--/[0-9a-f]{16}\\.gif$", key);
        Assert.NotEqual(key, AdminExercisesController.GifKey("../ab c/é", [.. Gif, 0]));
    }

    private static MultipartFormDataContent Form(byte[] bytes)
    {
        var file = new ByteArrayContent(bytes);
        file.Headers.ContentType = new MediaTypeHeaderValue("image/gif");
        return new MultipartFormDataContent { { file, "file", "demo.gif" } };
    }
}
