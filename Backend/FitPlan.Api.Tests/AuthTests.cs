using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Xunit;

namespace FitPlan.Api.Tests;

[Collection(ApiCollection.Name)]
public class AuthTests(ApiFixture api)
{
    private const string ProtectedRoute = "/api/profile/me";

    [Fact]
    public async Task Register_returns_created_and_a_token_that_opens_protected_routes()
    {
        var username = ApiFixture.NewUsername();

        var response = await api.CreateClient().PostAsJsonAsync(
            "/api/auth/register", new { username, password = ApiFixture.NewPassword() });

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var auth = await response.Content.ReadFromJsonAsync<AuthResponseDto>();
        Assert.Equal(username, auth!.Username);

        var profile = await api.CreateClient(auth.AccessToken).GetAsync(ProtectedRoute);
        Assert.Equal(HttpStatusCode.OK, profile.StatusCode);
    }

    [Fact]
    public async Task Register_stores_a_hash_and_never_the_password()
    {
        var user = await api.RegisterUserAsync();

        var hash = await api.WithDbContextAsync(context =>
            context.Users.Where(u => u.Id == user.Id).Select(u => u.PasswordHash).SingleAsync());

        Assert.NotEmpty(hash);
        Assert.DoesNotContain(user.Password, hash);
    }

    [Fact]
    public async Task Register_rejects_a_username_that_is_taken()
    {
        var user = await api.RegisterUserAsync();

        var response = await api.CreateClient().PostAsJsonAsync(
            "/api/auth/register", new { username = user.Username, password = ApiFixture.NewPassword() });

        await response.AssertProblemAsync(HttpStatusCode.Conflict, "UsernameAlreadyExists");
    }

    [Theory]
    [InlineData("ab", "long-enough-password")]
    [InlineData("valid-username", "short")]
    public async Task Register_rejects_invalid_input(string username, string password)
    {
        var response = await api.CreateClient().PostAsJsonAsync("/api/auth/register", new { username, password });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Login_with_the_correct_password_returns_a_working_token()
    {
        var user = await api.RegisterUserAsync();

        var response = await api.CreateClient().PostAsJsonAsync(
            "/api/auth/login", new { username = user.Username, password = user.Password });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var auth = await response.Content.ReadFromJsonAsync<AuthResponseDto>();
        Assert.Equal(user.Id, auth!.Id);

        var profile = await api.CreateClient(auth.AccessToken).GetAsync(ProtectedRoute);
        Assert.Equal(HttpStatusCode.OK, profile.StatusCode);
    }

    [Fact]
    public async Task Login_gives_the_same_error_for_a_wrong_password_and_an_unknown_user()
    {
        var user = await api.RegisterUserAsync();

        var wrongPassword = await api.CreateClient().PostAsJsonAsync(
            "/api/auth/login", new { username = user.Username, password = user.Password + "x" });
        var unknownUser = await api.CreateClient().PostAsJsonAsync(
            "/api/auth/login", new { username = ApiFixture.NewUsername(), password = user.Password });

        await wrongPassword.AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidCredentials");
        await unknownUser.AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidCredentials");
    }

    [Fact]
    public async Task Protected_route_rejects_a_request_without_a_token()
    {
        var response = await api.CreateClient().GetAsync(ProtectedRoute);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Control_token_built_by_the_test_helper_is_accepted()
    {
        // Proves the rejections below come from the one thing each of them changes.
        var user = await api.RegisterUserAsync();

        var response = await api.CreateClient(CreateToken(user.Id)).GetAsync(ProtectedRoute);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Protected_route_rejects_a_tampered_token()
    {
        var user = await api.RegisterUserAsync();
        var token = CreateToken(user.Id);
        var tampered = token[..^4] + (token.EndsWith("AAAA", StringComparison.Ordinal) ? "BBBB" : "AAAA");

        var response = await api.CreateClient(tampered).GetAsync(ProtectedRoute);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Protected_route_rejects_a_token_signed_with_another_key()
    {
        var user = await api.RegisterUserAsync();
        var otherKey = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));

        var response = await api.CreateClient(CreateToken(user.Id, key: otherKey)).GetAsync(ProtectedRoute);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Protected_route_rejects_an_expired_token()
    {
        var user = await api.RegisterUserAsync();

        var response = await api.CreateClient(CreateToken(user.Id, expires: DateTime.UtcNow.AddHours(-1)))
            .GetAsync(ProtectedRoute);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Protected_route_rejects_a_token_from_another_issuer()
    {
        var user = await api.RegisterUserAsync();

        var response = await api.CreateClient(CreateToken(user.Id, issuer: "someone-else"))
            .GetAsync(ProtectedRoute);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    private string CreateToken(Guid userId, string? key = null, DateTime? expires = null, string issuer = ApiFixture.JwtIssuer)
    {
        var expiry = expires ?? DateTime.UtcNow.AddMinutes(10);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: ApiFixture.JwtAudience,
            claims: [new Claim(ClaimTypes.NameIdentifier, userId.ToString())],
            notBefore: expiry.AddHours(-1),
            expires: expiry,
            signingCredentials: new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key ?? api.JwtKey)),
                SecurityAlgorithms.HmacSha512));

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
