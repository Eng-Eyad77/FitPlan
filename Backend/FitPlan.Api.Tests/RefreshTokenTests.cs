using System.Net;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Extensions;
using FitPlan.Api.Services.Auth;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

[Collection(ApiCollection.Name)]
public class RefreshTokenTests(ApiFixture api)
{
    private const string ProtectedRoute = "/api/profile/me";

    private async Task<AuthResponseDto> LoginAsync(TestUser user)
    {
        var response = await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { login = user.Username, user.Password });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<AuthResponseDto>())!;
    }

    private Task<HttpResponseMessage> RefreshAsync(string refreshToken) =>
        api.CreateClient().PostAsJsonAsync("/api/auth/refresh", new { refreshToken });

    private static string Hash(string token) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)));

    private Task MoveUsedAtBackAsync(string token, TimeSpan by) =>
        api.WithDbContextAsync(context => context.RefreshTokens
            .Where(t => t.TokenHash == Hash(token))
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.UsedAt, DateTime.UtcNow - by)));

    [Fact]
    public async Task Login_returns_a_refresh_token_that_is_stored_only_as_a_hash()
    {
        var user = await api.RegisterUserAsync();
        var auth = await LoginAsync(user);

        Assert.False(string.IsNullOrWhiteSpace(auth.RefreshToken));
        Assert.True(auth.RefreshTokenExpiresAt > DateTime.UtcNow.AddDays(29));

        var hashes = await api.WithDbContextAsync(context =>
            context.RefreshTokens.Where(t => t.UserId == user.Id).Select(t => t.TokenHash).ToListAsync());
        Assert.Contains(Hash(auth.RefreshToken), hashes);
        Assert.DoesNotContain(auth.RefreshToken, hashes);
    }

    [Fact]
    public async Task Register_also_returns_a_working_refresh_token()
    {
        var response = await api.SignUpAsync(ApiFixture.NewEmail(), ApiFixture.NewUsername(), ApiFixture.NewPassword());
        var auth = await response.Content.ReadFromJsonAsync<AuthResponseDto>();

        Assert.Equal(HttpStatusCode.OK, (await RefreshAsync(auth!.RefreshToken)).StatusCode);
    }

    [Fact]
    public async Task Refresh_gives_a_new_pair_and_the_new_access_token_works()
    {
        var auth = await LoginAsync(await api.RegisterUserAsync());

        var response = await RefreshAsync(auth.RefreshToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var next = (await response.Content.ReadFromJsonAsync<AuthResponseDto>())!;
        Assert.NotEqual(auth.RefreshToken, next.RefreshToken);
        Assert.Equal(HttpStatusCode.OK, (await api.CreateClient(next.AccessToken).GetAsync(ProtectedRoute)).StatusCode);
    }

    [Fact]
    public async Task A_lost_response_can_be_retried_within_the_grace_window()
    {
        var auth = await LoginAsync(await api.RegisterUserAsync());
        await RefreshAsync(auth.RefreshToken);

        var retry = await RefreshAsync(auth.RefreshToken);

        Assert.Equal(HttpStatusCode.OK, retry.StatusCode);
    }

    [Fact]
    public async Task Reusing_an_old_token_after_the_grace_window_ends_the_whole_login()
    {
        var auth = await LoginAsync(await api.RegisterUserAsync());
        var next = (await (await RefreshAsync(auth.RefreshToken)).Content.ReadFromJsonAsync<AuthResponseDto>())!;
        await MoveUsedAtBackAsync(auth.RefreshToken, AuthService.ReuseGrace + TimeSpan.FromSeconds(1));

        var reuse = await RefreshAsync(auth.RefreshToken);

        await reuse.AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidRefreshToken");
        await (await RefreshAsync(next.RefreshToken)).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidRefreshToken");
    }

    [Fact]
    public async Task An_expired_token_is_refused()
    {
        var auth = await LoginAsync(await api.RegisterUserAsync());
        await api.WithDbContextAsync(context => context.RefreshTokens
            .Where(t => t.TokenHash == Hash(auth.RefreshToken))
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.ExpiresAt, DateTime.UtcNow.AddSeconds(-1))));

        await (await RefreshAsync(auth.RefreshToken)).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidRefreshToken");
    }

    [Theory]
    [InlineData("not-a-real-token")]
    [InlineData("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")]
    public async Task An_unknown_token_is_refused(string token)
    {
        await (await RefreshAsync(token)).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidRefreshToken");
    }

    [Fact]
    public async Task A_missing_token_is_a_validation_error()
    {
        var response = await api.CreateClient().PostAsJsonAsync("/api/auth/refresh", new { });

        await response.AssertProblemAsync(HttpStatusCode.BadRequest, "ValidationFailed");
    }

    [Fact]
    public async Task Logout_ends_only_that_login()
    {
        var user = await api.RegisterUserAsync();
        var phone = await LoginAsync(user);
        var tablet = await LoginAsync(user);

        var logout = await api.CreateClient().PostAsJsonAsync("/api/auth/logout", new { refreshToken = phone.RefreshToken });

        Assert.Equal(HttpStatusCode.NoContent, logout.StatusCode);
        await (await RefreshAsync(phone.RefreshToken)).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidRefreshToken");
        Assert.Equal(HttpStatusCode.OK, (await RefreshAsync(tablet.RefreshToken)).StatusCode);
    }

    [Fact]
    public async Task Logout_with_an_unknown_token_reveals_nothing()
    {
        var logout = await api.CreateClient().PostAsJsonAsync("/api/auth/logout", new { refreshToken = "unknown" });

        Assert.Equal(HttpStatusCode.NoContent, logout.StatusCode);
    }

    [Fact]
    public async Task Too_many_logins_from_one_caller_get_429_with_Retry_After()
    {
        var client = api.CreateClient();
        var body = new { login = ApiFixture.NewUsername(), password = "wrong-password-123" };

        for (var i = 0; i < RateLimitingExtensions.SignInPermitPerMinute; i++)
        {
            Assert.Equal(HttpStatusCode.Unauthorized, (await client.PostAsJsonAsync("/api/auth/login", body)).StatusCode);
        }

        var limited = await client.PostAsJsonAsync("/api/auth/login", body);

        await limited.AssertProblemAsync(HttpStatusCode.TooManyRequests, "TooManyRequests");
        Assert.True(limited.Headers.RetryAfter is not null);

        // another caller isn't affected
        Assert.Equal(HttpStatusCode.Unauthorized, (await api.CreateClient().PostAsJsonAsync("/api/auth/login", body)).StatusCode);
    }

    [Fact]
    public async Task Sign_up_shares_the_sign_in_limit()
    {
        var client = api.CreateClient();
        for (var i = 0; i < RateLimitingExtensions.SignInPermitPerMinute; i++)
        {
            await client.PostAsJsonAsync("/api/auth/login", new { login = "x", password = "wrong-password-123" });
        }

        var register = await client.PostAsJsonAsync(
            "/api/auth/register", new { email = ApiFixture.NewEmail(), code = "123456", username = ApiFixture.NewUsername(), password = ApiFixture.NewPassword() });

        await register.AssertProblemAsync(HttpStatusCode.TooManyRequests, "TooManyRequests");
    }
}
