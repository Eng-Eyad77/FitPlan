using System.Net;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Admin;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

[Collection(ApiCollection.Name)]
public class AdminTests(ApiFixture api)
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() }
    };

    private static readonly string[] AdminRoutes = ["/api/admin/me", "/api/admin/audit"];

    // RFC 6238, appendix B (SHA-1 rows)
    [Theory]
    [InlineData(59, "94287082")]
    [InlineData(1111111109, "07081804")]
    [InlineData(2000000000, "69279037")]
    public void Totp_matches_the_rfc_test_vectors(long unixSeconds, string expected)
    {
        var key = Encoding.ASCII.GetBytes("12345678901234567890");

        Assert.Equal(expected, Totp.Code(key, Totp.StepAt(DateTimeOffset.FromUnixTimeSeconds(unixSeconds)), 8));
        Assert.Equal(key, Totp.FromBase32(Totp.ToBase32(key)));
    }

    [Fact]
    public async Task Admin_routes_refuse_no_token_and_a_normal_users_token()
    {
        var user = await api.RegisterUserAsync();

        foreach (var route in AdminRoutes)
        {
            Assert.Equal(HttpStatusCode.Unauthorized, (await api.CreateClient().GetAsync(route)).StatusCode);
            Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.GetAsync(route)).StatusCode);
        }
    }

    [Fact]
    public async Task The_owners_phone_app_token_does_not_open_admin_routes()
    {
        var (owner, _) = await MakeOwnerAsync();

        Assert.Equal(HttpStatusCode.Forbidden, (await owner.Client.GetAsync("/api/admin/me")).StatusCode);
    }

    [Fact]
    public async Task Owner_signs_in_with_password_and_code_and_it_is_logged()
    {
        var (owner, secret) = await MakeOwnerAsync();

        var response = await SignInAsync(owner.Username, owner.Password, CodeNow(secret));

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var auth = await response.Content.ReadFromJsonAsync<AdminSignInResponseDto>(Json);
        var admin = api.CreateClient(auth!.AccessToken);

        var me = await admin.GetFromJsonAsync<AdminMeDto>("/api/admin/me", Json);
        Assert.Equal(owner.Username, me!.Username);
        Assert.Equal(AdminRole.Owner, me.Role);

        Assert.Equal(HttpStatusCode.OK, (await admin.GetAsync("/api/admin/audit")).StatusCode);
        Assert.True(await api.WithDbContextAsync(c => c.AdminAuditEntries.AnyAsync(e => e.AdminUserId == owner.Id && e.Action == "Signed in")));
    }

    [Fact]
    public async Task A_code_works_only_once()
    {
        var (owner, secret) = await MakeOwnerAsync();
        var code = CodeNow(secret);

        Assert.Equal(HttpStatusCode.OK, (await SignInAsync(owner.Username, owner.Password, code)).StatusCode);
        await (await SignInAsync(owner.Username, owner.Password, code)).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidAdminSignIn");
    }

    [Fact]
    public async Task Wrong_code_wrong_password_and_non_admin_get_the_same_error()
    {
        var (owner, secret) = await MakeOwnerAsync();
        var user = await api.RegisterUserAsync();
        var wrongCode = CodeNow(secret) == "000000" ? "111111" : "000000";

        await (await SignInAsync(owner.Username, owner.Password, wrongCode)).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidAdminSignIn");
        await (await SignInAsync(owner.Username, owner.Password + "x", CodeNow(secret))).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidAdminSignIn");
        await (await SignInAsync(user.Username, user.Password, CodeNow(secret))).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidAdminSignIn");
    }

    [Fact]
    public async Task A_removed_admin_loses_access_at_once()
    {
        var (owner, secret) = await MakeOwnerAsync();
        var auth = await (await SignInAsync(owner.Username, owner.Password, CodeNow(secret))).Content.ReadFromJsonAsync<AdminSignInResponseDto>(Json);

        await api.WithDbContextAsync(c => c.AdminAccounts.Where(a => a.UserId == owner.Id).ExecuteDeleteAsync());

        Assert.Equal(HttpStatusCode.Unauthorized, (await api.CreateClient(auth!.AccessToken).GetAsync("/api/admin/me")).StatusCode);
    }

    private async Task<(TestUser Owner, string Secret)> MakeOwnerAsync()
    {
        var owner = await api.RegisterUserAsync();
        var secret = Totp.NewSecret();
        await api.WithDbContextAsync(async c =>
        {
            c.AdminAccounts.Add(new AdminAccount { UserId = owner.Id, Role = AdminRole.Owner, TotpSecret = secret, CreatedAt = DateTime.UtcNow });
            await c.SaveChangesAsync();
        });

        return (owner, secret);
    }

    private static string CodeNow(string secret) => Totp.Code(Totp.FromBase32(secret), Totp.StepAt(DateTimeOffset.UtcNow), 6);

    private Task<HttpResponseMessage> SignInAsync(string login, string password, string code) =>
        api.CreateClient().PostAsJsonAsync("/api/admin/auth/login", new { login, password, code });
}
