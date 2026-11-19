using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.DTOs.Profile;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Auth;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 5B and 5C: pictures only for their owner, real image checks, recovery codes and account deletion.
[Collection(ApiCollection.Name)]
public class AccountTests(ApiFixture api)
{
    private static readonly byte[] Png =
    [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
        0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
        0x42, 0x60, 0x82
    ];

    private static readonly byte[] Jpeg = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01];

    private static MultipartFormDataContent Upload(byte[] bytes, string fileName, string contentType)
    {
        var file = new ByteArrayContent(bytes);
        file.Headers.ContentType = new MediaTypeHeaderValue(contentType);
        return new MultipartFormDataContent { { file, "file", fileName } };
    }

    private async Task<ProfileDto> UploadAsync(TestUser user, byte[] bytes, string fileName = "me.png", string contentType = "image/png")
    {
        var response = await user.Client.PostAsync("/api/profile/me/picture", Upload(bytes, fileName, contentType));
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<ProfileDto>())!;
    }

    private string PictureFile(string url) =>
        Path.Combine(api.UploadsRoot, "profile-pictures", Path.GetFileName(url));

    // ---------------------------------------------------------------- pictures

    [Fact]
    public async Task The_picture_is_served_only_to_its_signed_in_owner()
    {
        var user = await api.RegisterUserAsync();
        await UploadAsync(user, Png);

        var mine = await user.Client.GetAsync("/api/profile/me/picture");
        var anonymous = await api.CreateClient().GetAsync("/api/profile/me/picture");

        Assert.Equal(HttpStatusCode.OK, mine.StatusCode);
        Assert.Equal("image/png", mine.Content.Headers.ContentType?.MediaType);
        Assert.Equal(Png, await mine.Content.ReadAsByteArrayAsync());
        Assert.Equal(HttpStatusCode.Unauthorized, anonymous.StatusCode);
    }

    [Fact]
    public async Task Another_user_gets_their_own_picture_not_mine()
    {
        var owner = await api.RegisterUserAsync();
        await UploadAsync(owner, Png);
        var other = await api.RegisterUserAsync();

        var response = await other.Client.GetAsync("/api/profile/me/picture");

        await response.AssertProblemAsync(HttpStatusCode.NotFound, "PictureNotFound");
    }

    [Fact]
    public async Task A_file_that_only_claims_to_be_an_image_is_rejected()
    {
        var user = await api.RegisterUserAsync();
        var text = "<script>alert(1)</script>"u8.ToArray();

        var response = await user.Client.PostAsync("/api/profile/me/picture", Upload(text, "cat.jpg", "image/jpeg"));

        await response.AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidFile");
        Assert.Empty(Directory.Exists(Path.Combine(api.UploadsRoot, "profile-pictures"))
            ? Directory.GetFiles(Path.Combine(api.UploadsRoot, "profile-pictures"), "*", SearchOption.TopDirectoryOnly)
                .Where(f => File.ReadAllBytes(f).SequenceEqual(text))
            : []);
    }

    [Fact]
    public async Task The_saved_type_comes_from_the_bytes_not_the_name()
    {
        var user = await api.RegisterUserAsync();

        var profile = await UploadAsync(user, Jpeg, fileName: "photo.png", contentType: "image/png");

        Assert.EndsWith(".jpg", profile.ProfilePictureUrl);
        var served = await user.Client.GetAsync("/api/profile/me/picture");
        Assert.Equal("image/jpeg", served.Content.Headers.ContentType?.MediaType);
    }

    [Fact]
    public async Task A_new_picture_replaces_the_old_file()
    {
        var user = await api.RegisterUserAsync();
        var first = await UploadAsync(user, Png);

        var second = await UploadAsync(user, Jpeg, "me.jpg", "image/jpeg");

        Assert.False(File.Exists(PictureFile(first.ProfilePictureUrl!)));
        Assert.True(File.Exists(PictureFile(second.ProfilePictureUrl!)));
    }

    // ---------------------------------------------------------------- recovery codes

    [Fact]
    public async Task Sign_up_returns_a_recovery_code_stored_only_as_a_hash()
    {
        var response = await api.CreateClient().PostAsJsonAsync(
            "/api/auth/register", new { username = ApiFixture.NewUsername(), password = ApiFixture.NewPassword() });
        var auth = (await response.Content.ReadFromJsonAsync<AuthResponseDto>())!;

        Assert.Matches("^[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$", auth.RecoveryCode);
        var hash = await api.WithDbContextAsync(c => c.Users.Where(u => u.Id == auth.Id).Select(u => u.RecoveryCodeHash).SingleAsync());
        Assert.NotNull(hash);
        Assert.DoesNotContain(RecoveryCodes.Normalize(auth.RecoveryCode!), hash);
    }

    [Fact]
    public async Task Login_and_refresh_never_return_a_recovery_code()
    {
        var user = await api.RegisterUserAsync();

        var login = await (await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { user.Username, user.Password }))
            .Content.ReadFromJsonAsync<AuthResponseDto>();

        Assert.Null(login!.RecoveryCode);
    }

    private async Task<(TestUser User, string Code)> RegisterWithCodeAsync()
    {
        var username = ApiFixture.NewUsername();
        var password = ApiFixture.NewPassword();
        var auth = (await (await api.CreateClient().PostAsJsonAsync("/api/auth/register", new { username, password }))
            .Content.ReadFromJsonAsync<AuthResponseDto>())!;
        return (new TestUser(auth.Id, username, password, api.CreateClient(auth.AccessToken)), auth.RecoveryCode!);
    }

    private Task<HttpResponseMessage> ResetAsync(string username, string code, string newPassword) =>
        api.CreateClient().PostAsJsonAsync("/api/auth/reset-password", new { username, recoveryCode = code, newPassword });

    [Fact]
    public async Task A_recovery_code_resets_the_password_and_ends_the_other_logins()
    {
        var (user, code) = await RegisterWithCodeAsync();
        var oldLogin = (await (await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { user.Username, user.Password }))
            .Content.ReadFromJsonAsync<AuthResponseDto>())!;
        var newPassword = ApiFixture.NewPassword();

        // typed the way people do: lower case and spaces
        var reset = await ResetAsync(user.Username, code.ToLowerInvariant().Replace("-", " "), newPassword);

        Assert.Equal(HttpStatusCode.OK, reset.StatusCode);
        var auth = (await reset.Content.ReadFromJsonAsync<AuthResponseDto>())!;
        Assert.NotNull(auth.RecoveryCode);
        Assert.NotEqual(code, auth.RecoveryCode);
        Assert.Equal(HttpStatusCode.OK, (await api.CreateClient(auth.AccessToken).GetAsync("/api/profile/me")).StatusCode);

        var oldPassword = await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { user.Username, user.Password });
        await oldPassword.AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidCredentials");
        var newLogin = await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { user.Username, password = newPassword });
        Assert.Equal(HttpStatusCode.OK, newLogin.StatusCode);

        var oldRefresh = await api.CreateClient().PostAsJsonAsync("/api/auth/refresh", new { refreshToken = oldLogin.RefreshToken });
        await oldRefresh.AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidRefreshToken");
    }

    [Fact]
    public async Task A_recovery_code_works_only_once()
    {
        var (user, code) = await RegisterWithCodeAsync();
        (await ResetAsync(user.Username, code, ApiFixture.NewPassword())).EnsureSuccessStatusCode();

        var again = await ResetAsync(user.Username, code, ApiFixture.NewPassword());

        await again.AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidRecoveryCode");
    }

    [Fact]
    public async Task A_wrong_code_and_an_unknown_user_get_the_same_answer()
    {
        var (user, _) = await RegisterWithCodeAsync();

        var wrongCode = await ResetAsync(user.Username, "AAAA-BBBB-CCCC-DDDD", ApiFixture.NewPassword());
        var unknownUser = await ResetAsync(ApiFixture.NewUsername(), "AAAA-BBBB-CCCC-DDDD", ApiFixture.NewPassword());

        await wrongCode.AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidRecoveryCode");
        await unknownUser.AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidRecoveryCode");
        Assert.Equal(HttpStatusCode.OK, (await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { user.Username, user.Password })).StatusCode);
    }

    [Fact]
    public async Task A_new_code_needs_the_password_and_replaces_the_old_one()
    {
        var (user, oldCode) = await RegisterWithCodeAsync();

        var wrong = await user.Client.PostAsJsonAsync("/api/profile/me/recovery-code", new { password = "not-my-password" });
        var created = await user.Client.PostAsJsonAsync("/api/profile/me/recovery-code", new { password = user.Password });

        // a wrong password while signed in must not be 401, or the app would end the session
        await wrong.AssertProblemAsync(HttpStatusCode.BadRequest, "WrongPassword");
        Assert.Equal(HttpStatusCode.OK, created.StatusCode);
        var newCode = (await created.Content.ReadFromJsonAsync<RecoveryCodeDto>())!.RecoveryCode;

        await (await ResetAsync(user.Username, oldCode, ApiFixture.NewPassword())).AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidRecoveryCode");
        Assert.Equal(HttpStatusCode.OK, (await ResetAsync(user.Username, newCode, ApiFixture.NewPassword())).StatusCode);
    }

    [Fact]
    public async Task The_profile_says_whether_a_recovery_code_exists()
    {
        var user = await api.RegisterUserAsync();
        await api.WithDbContextAsync(c => c.Users.Where(u => u.Id == user.Id)
            .ExecuteUpdateAsync(s => s.SetProperty(u => u.RecoveryCodeHash, (string?)null)));

        var before = await user.Client.GetFromJsonAsync<ProfileDto>("/api/profile/me");
        await user.Client.PostAsJsonAsync("/api/profile/me/recovery-code", new { password = user.Password });
        var after = await user.Client.GetFromJsonAsync<ProfileDto>("/api/profile/me");

        Assert.False(before!.HasRecoveryCode);
        Assert.True(after!.HasRecoveryCode);
    }

    // ---------------------------------------------------------------- account deletion

    private async Task GiveFullDataAsync(Guid userId)
    {
        var exerciseId = await api.AddExerciseAsync();
        await api.WithDbContextAsync(async context =>
        {
            var plan = new WorkoutPlan { Id = Guid.NewGuid(), Name = "Push", UserId = userId, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow };
            context.WorkoutPlans.Add(plan);
            context.WorkoutPlanExercises.Add(new WorkoutPlanExercise { Id = Guid.NewGuid(), WorkoutPlanId = plan.Id, ExerciseId = exerciseId, Sets = 3, Reps = 10, Order = 1 });
            var session = new WorkoutSession { Id = Guid.NewGuid(), UserId = userId, WorkoutPlanId = plan.Id, Name = "Push", StartedAt = DateTime.UtcNow, CompletedAt = DateTime.UtcNow };
            context.WorkoutSessions.Add(session);
            var done = new SessionExercise { Id = Guid.NewGuid(), WorkoutSessionId = session.Id, ExerciseId = exerciseId, Order = 1 };
            context.SessionExercises.Add(done);
            context.SessionSets.Add(new SessionSet { Id = Guid.NewGuid(), SessionExerciseId = done.Id, SetNumber = 1, Reps = 10, WeightKg = 50 });
            context.CardioEntries.Add(new CardioEntry { Id = Guid.NewGuid(), WorkoutSessionId = session.Id, Machine = CardioMachine.Treadmill, DurationSeconds = 600, RecordedAt = DateTime.UtcNow });
            context.BodyWeightEntries.Add(new BodyWeightEntry { Id = Guid.NewGuid(), UserId = userId, WeightKg = 80, RecordedAt = DateTime.UtcNow });
            await context.SaveChangesAsync();
        });
    }

    private Task<int> RowsOwnedByAsync(Guid userId) => api.WithDbContextAsync(async c =>
        await c.Users.CountAsync(u => u.Id == userId)
        + await c.WorkoutPlans.CountAsync(p => p.UserId == userId)
        + await c.WorkoutPlanExercises.CountAsync(e => e.WorkoutPlan.UserId == userId)
        + await c.WorkoutSessions.CountAsync(s => s.UserId == userId)
        + await c.SessionExercises.CountAsync(e => e.WorkoutSession.UserId == userId)
        + await c.SessionSets.CountAsync(s => s.SessionExercise.WorkoutSession.UserId == userId)
        + await c.CardioEntries.CountAsync(e => e.WorkoutSession.UserId == userId)
        + await c.BodyWeightEntries.CountAsync(w => w.UserId == userId)
        + await c.RefreshTokens.CountAsync(t => t.UserId == userId));

    [Fact]
    public async Task Deleting_the_account_removes_every_row_and_the_picture()
    {
        var user = await api.RegisterUserAsync();
        var picture = (await UploadAsync(user, Png)).ProfilePictureUrl!;
        await GiveFullDataAsync(user.Id);
        var other = await api.RegisterUserAsync();
        await GiveFullDataAsync(other.Id);
        var otherRows = await RowsOwnedByAsync(other.Id);
        Assert.True(await RowsOwnedByAsync(user.Id) >= 9);

        var response = await user.Client.PostAsJsonAsync("/api/profile/me/delete", new { password = user.Password });

        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
        Assert.Equal(0, await RowsOwnedByAsync(user.Id));
        Assert.False(File.Exists(PictureFile(picture)));
        Assert.Equal(otherRows, await RowsOwnedByAsync(other.Id));
    }

    [Fact]
    public async Task After_deletion_the_old_tokens_stop_working()
    {
        var user = await api.RegisterUserAsync();
        var login = (await (await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { user.Username, user.Password }))
            .Content.ReadFromJsonAsync<AuthResponseDto>())!;

        (await user.Client.PostAsJsonAsync("/api/profile/me/delete", new { password = user.Password })).EnsureSuccessStatusCode();

        Assert.Equal(HttpStatusCode.Unauthorized, (await user.Client.GetAsync("/api/profile/me")).StatusCode);
        await (await api.CreateClient().PostAsJsonAsync("/api/auth/refresh", new { refreshToken = login.RefreshToken }))
            .AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidRefreshToken");
        await (await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { user.Username, user.Password }))
            .AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidCredentials");
    }

    [Fact]
    public async Task A_wrong_password_deletes_nothing_and_is_not_401()
    {
        var user = await api.RegisterUserAsync();
        await GiveFullDataAsync(user.Id);
        var before = await RowsOwnedByAsync(user.Id);

        var response = await user.Client.PostAsJsonAsync("/api/profile/me/delete", new { password = "not-my-password" });

        await response.AssertProblemAsync(HttpStatusCode.BadRequest, "WrongPassword");
        Assert.Equal(before, await RowsOwnedByAsync(user.Id));
    }

    [Fact]
    public async Task A_signed_in_user_can_still_browse_exercises_without_a_user_check()
    {
        var user = await api.RegisterUserAsync();
        (await user.Client.PostAsJsonAsync("/api/profile/me/delete", new { password = user.Password })).EnsureSuccessStatusCode();

        // the exercise library is open, so even a deleted account's token doesn't block it
        Assert.Equal(HttpStatusCode.OK, (await user.Client.GetAsync("/api/exercises?pageSize=1")).StatusCode);
    }
}
