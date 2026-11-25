using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 12B: users and accounts.
[Collection(ApiCollection.Name)]
public class AdminUsersTests(ApiFixture api)
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    [Fact]
    public async Task Every_users_route_refuses_a_normal_user()
    {
        var user = await api.RegisterUserAsync();
        var id = user.Id;

        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.GetAsync("/api/admin/users")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.GetAsync($"/api/admin/users/{id}")).StatusCode);
        foreach (var action in new[] { "reveal-email", "disable", "enable", "end-sessions" })
        {
            Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.PostAsync($"/api/admin/users/{id}/{action}", null)).StatusCode);
        }

        Assert.Equal(HttpStatusCode.Forbidden,
            (await user.Client.PostAsJsonAsync($"/api/admin/users/{id}/delete", new { username = user.Username })).StatusCode);
    }

    [Fact]
    public async Task Search_finds_a_user_with_a_masked_email_and_never_a_password()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();

        var body = await admin.GetStringAsync($"/api/admin/users?search={user.Username}");

        Assert.Contains(user.Username, body);
        Assert.Contains(user.Email[0] + "***@example.test", body);
        Assert.DoesNotContain(user.Email, body);
        Assert.DoesNotContain("password", body, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task Showing_the_email_works_and_is_logged()
    {
        var (owner, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();

        var shown = await (await admin.PostAsync($"/api/admin/users/{user.Id}/reveal-email", null)).Content.ReadFromJsonAsync<AdminUserEmailDto>(Json);

        Assert.Equal(user.Email, shown!.Email);
        Assert.True(await LoggedAsync(owner.Id, "Showed email", user.Username));
    }

    [Fact]
    public async Task A_disabled_user_cant_sign_in_refresh_or_use_their_token_until_enabled()
    {
        var (owner, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();
        var login = await (await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { login = user.Username, password = user.Password }))
            .Content.ReadFromJsonAsync<AuthResponseDto>();

        Assert.Equal(HttpStatusCode.NoContent, (await admin.PostAsync($"/api/admin/users/{user.Id}/disable", null)).StatusCode);

        Assert.Equal(HttpStatusCode.Unauthorized, (await user.Client.GetAsync("/api/profile/me")).StatusCode);
        await (await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { login = user.Username, password = user.Password }))
            .AssertProblemAsync(HttpStatusCode.Unauthorized, "AccountDisabled");
        await (await api.CreateClient().PostAsJsonAsync("/api/auth/refresh", new { refreshToken = login!.RefreshToken }))
            .AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidRefreshToken");
        Assert.True(await LoggedAsync(owner.Id, "Disabled account", user.Username));

        Assert.Equal(HttpStatusCode.NoContent, (await admin.PostAsync($"/api/admin/users/{user.Id}/enable", null)).StatusCode);
        Assert.Equal(HttpStatusCode.OK,
            (await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { login = user.Username, password = user.Password })).StatusCode);
    }

    [Fact]
    public async Task A_disabled_user_cant_get_back_in_with_a_password_reset()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();
        await admin.PostAsync($"/api/admin/users/{user.Id}/disable", null);

        // the sign-up code was just sent; codes to one address must be a minute apart
        await api.WithDbContextAsync(c => c.EmailCodes.Where(e => e.Email == user.Email)
            .ExecuteUpdateAsync(s => s.SetProperty(e => e.CreatedAt, e => e.CreatedAt.AddMinutes(-2))));
        var client = api.CreateClient();
        (await client.PostAsJsonAsync("/api/auth/password-reset/code", new { email = user.Email })).EnsureSuccessStatusCode();
        var reset = await client.PostAsJsonAsync("/api/auth/reset-password",
            new { email = user.Email, code = api.Emails.LastCode(user.Email), newPassword = ApiFixture.NewPassword() });

        await reset.AssertProblemAsync(HttpStatusCode.Unauthorized, "AccountDisabled");
    }

    [Fact]
    public async Task Ending_sessions_stops_the_refresh_token()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();
        var login = await (await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { login = user.Username, password = user.Password }))
            .Content.ReadFromJsonAsync<AuthResponseDto>();

        Assert.Equal(HttpStatusCode.NoContent, (await admin.PostAsync($"/api/admin/users/{user.Id}/end-sessions", null)).StatusCode);

        await (await api.CreateClient().PostAsJsonAsync("/api/auth/refresh", new { refreshToken = login!.RefreshToken }))
            .AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidRefreshToken");
    }

    [Fact]
    public async Task Delete_needs_the_username_and_keeps_the_audit_entry()
    {
        var (owner, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();

        await (await admin.PostAsJsonAsync($"/api/admin/users/{user.Id}/delete", new { username = "someone-else" }))
            .AssertProblemAsync(HttpStatusCode.BadRequest, "ConfirmationMismatch");
        Assert.Equal(HttpStatusCode.NoContent,
            (await admin.PostAsJsonAsync($"/api/admin/users/{user.Id}/delete", new { username = user.Username })).StatusCode);

        Assert.False(await api.WithDbContextAsync(c => c.Users.AnyAsync(u => u.Id == user.Id)));
        Assert.True(await LoggedAsync(owner.Id, "Deleted account", user.Username));
    }

    [Fact]
    public async Task An_admin_account_cant_be_disabled_or_deleted()
    {
        var (owner, admin) = await api.SignInAsOwnerAsync();

        await (await admin.PostAsync($"/api/admin/users/{owner.Id}/disable", null))
            .AssertProblemAsync(HttpStatusCode.Conflict, "AdminAccountProtected");
        await (await admin.PostAsJsonAsync($"/api/admin/users/{owner.Id}/delete", new { username = owner.Username }))
            .AssertProblemAsync(HttpStatusCode.Conflict, "AdminAccountProtected");
    }

    [Fact]
    public async Task Details_count_workouts_devices_and_reports()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();

        var detail = await admin.GetFromJsonAsync<AdminUserDetailDto>($"/api/admin/users/{user.Id}", Json);

        Assert.Equal(user.Username, detail!.Username);
        Assert.Equal(0, detail.Workouts);
        Assert.Equal(1, detail.SignedInDevices);
        Assert.False(detail.IsAdmin);
        Assert.Null(detail.DisabledAt);
    }

    private Task<bool> LoggedAsync(Guid adminId, string action, string target) =>
        api.WithDbContextAsync(c => c.AdminAuditEntries.AnyAsync(e => e.AdminUserId == adminId && e.Action == action && e.Target == target));
}
