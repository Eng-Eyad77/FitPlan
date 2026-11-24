using System.Net;
using System.Net.Http.Json;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.DTOs.Profile;
using FitPlan.Api.Services.Email;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 11.5A (D18): email sign-up, sign-in with email or username, reset and email change by code.
[Collection(ApiCollection.Name)]
public class EmailAccountTests(ApiFixture api)
{
    private Task<HttpResponseMessage> SendSignUpCodeAsync(string email, HttpClient? client = null) =>
        (client ?? api.CreateClient()).PostAsJsonAsync("/api/auth/register/code", new { email });

    private Task<HttpResponseMessage> RegisterAsync(string email, string code, string? username = null) =>
        api.CreateClient().PostAsJsonAsync("/api/auth/register",
            new { email, code, username = username ?? ApiFixture.NewUsername(), password = ApiFixture.NewPassword() });

    private Task<HttpResponseMessage> LoginAsync(string login, string password) =>
        api.CreateClient().PostAsJsonAsync("/api/auth/login", new { login, password });

    private Task<HttpResponseMessage> SendResetCodeAsync(string email) =>
        api.CreateClient().PostAsJsonAsync("/api/auth/password-reset/code", new { email });

    private Task<HttpResponseMessage> ResetAsync(string email, string code, string newPassword) =>
        api.CreateClient().PostAsJsonAsync("/api/auth/reset-password", new { email, code, newPassword });

    // The per-address quota allows one email a minute; tests that need another move the earlier ones back.
    private Task AgeEmailsAsync(string email) =>
        api.WithDbContextAsync(c => c.EmailCodes.Where(e => e.Email == email)
            .ExecuteUpdateAsync(s => s.SetProperty(e => e.CreatedAt, e => e.CreatedAt.AddMinutes(-2))));

    private static string WrongCode(string code) => code == "000000" ? "111111" : "000000";

    // ---------------------------------------------------------------- sign-up

    [Fact]
    public async Task Sign_up_needs_the_emailed_code_and_stores_the_email_in_lower_case()
    {
        var email = ApiFixture.NewEmail();
        var username = ApiFixture.NewUsername();

        var response = await api.SignUpAsync(email.ToUpperInvariant(), username, ApiFixture.NewPassword());

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var stored = await api.WithDbContextAsync(c => c.Users.Where(u => u.Username == username).Select(u => u.Email).SingleAsync());
        Assert.Equal(email, stored);
    }

    [Fact]
    public async Task A_registered_email_gets_the_same_answer_but_a_notice_instead_of_a_code()
    {
        var user = await api.RegisterUserAsync();
        await AgeEmailsAsync(user.Email);

        var response = await SendSignUpCodeAsync(user.Email);

        Assert.Equal(HttpStatusCode.Accepted, response.StatusCode);
        var last = api.Emails.To(user.Email)[^1];
        Assert.Equal(EmailTexts.AlreadyRegistered("en"), last);
        Assert.DoesNotMatch(@"\b\d{6}\b", last.Body);
    }

    [Fact]
    public async Task A_wrong_code_is_rejected_and_five_wrong_tries_lock_the_code()
    {
        var email = ApiFixture.NewEmail();
        await SendSignUpCodeAsync(email);
        var code = api.Emails.LastCode(email);

        for (var i = 0; i < EmailCodeService.MaxAttempts; i++)
        {
            await (await RegisterAsync(email, WrongCode(code))).AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidEmailCode");
        }

        await (await RegisterAsync(email, code)).AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidEmailCode");
    }

    [Fact]
    public async Task A_code_works_only_once_and_a_taken_username_does_not_use_it_up()
    {
        var taken = await api.RegisterUserAsync();
        var email = ApiFixture.NewEmail();
        await SendSignUpCodeAsync(email);
        var code = api.Emails.LastCode(email);

        await (await RegisterAsync(email, code, taken.Username)).AssertProblemAsync(HttpStatusCode.Conflict, "UsernameAlreadyExists");
        Assert.Equal(HttpStatusCode.Created, (await RegisterAsync(email, code)).StatusCode);
        await (await RegisterAsync(email, code)).AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidEmailCode");
    }

    [Fact]
    public async Task An_expired_code_is_rejected()
    {
        var email = ApiFixture.NewEmail();
        await SendSignUpCodeAsync(email);
        await api.WithDbContextAsync(c => c.EmailCodes.Where(e => e.Email == email)
            .ExecuteUpdateAsync(s => s.SetProperty(e => e.ExpiresAt, DateTime.UtcNow.AddSeconds(-1))));

        var response = await RegisterAsync(email, api.Emails.LastCode(email));

        await response.AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidEmailCode");
    }

    [Fact]
    public async Task Only_the_newest_code_works()
    {
        var email = ApiFixture.NewEmail();
        await SendSignUpCodeAsync(email);
        var first = api.Emails.LastCode(email);
        await AgeEmailsAsync(email);
        await SendSignUpCodeAsync(email);
        var second = api.Emails.LastCode(email);

        if (first != second)
        {
            await (await RegisterAsync(email, first)).AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidEmailCode");
        }

        Assert.Equal(HttpStatusCode.Created, (await RegisterAsync(email, second)).StatusCode);
    }

    [Fact]
    public async Task An_address_gets_at_most_one_email_a_minute()
    {
        var email = ApiFixture.NewEmail();
        Assert.Equal(HttpStatusCode.Accepted, (await SendSignUpCodeAsync(email)).StatusCode);

        var again = await SendSignUpCodeAsync(email);

        await again.AssertProblemAsync(HttpStatusCode.TooManyRequests, "TooManyEmails");
        Assert.Single(api.Emails.To(email));
    }

    [Fact]
    public async Task An_address_gets_at_most_five_emails_an_hour()
    {
        var email = ApiFixture.NewEmail();
        for (var i = 0; i < EmailCodeService.MaxPerHour; i++)
        {
            Assert.Equal(HttpStatusCode.Accepted, (await SendSignUpCodeAsync(email)).StatusCode);
            await AgeEmailsAsync(email);
        }

        await (await SendSignUpCodeAsync(email)).AssertProblemAsync(HttpStatusCode.TooManyRequests, "TooManyEmails");
    }

    [Fact]
    public async Task A_username_with_an_at_sign_is_rejected()
    {
        var response = await RegisterAsync(ApiFixture.NewEmail(), "123456", "me@home");

        await response.AssertProblemAsync(HttpStatusCode.BadRequest, "ValidationFailed");
    }

    [Fact]
    public async Task A_failed_send_is_reported_as_503()
    {
        api.Emails.Fail = true;
        try
        {
            var response = await SendSignUpCodeAsync(ApiFixture.NewEmail());

            await response.AssertProblemAsync(HttpStatusCode.ServiceUnavailable, "EmailNotSent");
        }
        finally
        {
            api.Emails.Fail = false;
        }
    }

    [Fact]
    public async Task The_email_is_in_the_language_the_app_asks_for()
    {
        var email = ApiFixture.NewEmail();
        var client = api.CreateClient();
        client.DefaultRequestHeaders.AcceptLanguage.ParseAdd("ar");

        await SendSignUpCodeAsync(email, client);

        Assert.StartsWith("رمز FitPlan", api.Emails.To(email)[^1].Subject);
    }

    // ---------------------------------------------------------------- sign-in

    [Fact]
    public async Task Sign_in_works_with_the_email_in_any_case_and_with_the_username()
    {
        var user = await api.RegisterUserAsync();

        Assert.Equal(HttpStatusCode.OK, (await LoginAsync(user.Email.ToUpperInvariant(), user.Password)).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await LoginAsync(user.Username, user.Password)).StatusCode);
        await (await LoginAsync(user.Email, user.Password + "x")).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidCredentials");
    }

    // ---------------------------------------------------------------- password reset

    [Fact]
    public async Task An_unknown_email_gets_the_same_answer_and_no_email()
    {
        var email = ApiFixture.NewEmail();

        var response = await SendResetCodeAsync(email);

        Assert.Equal(HttpStatusCode.Accepted, response.StatusCode);
        Assert.Empty(api.Emails.To(email));
    }

    [Fact]
    public async Task A_reset_code_sets_the_new_password_and_ends_the_other_logins()
    {
        var user = await api.RegisterUserAsync();
        var oldLogin = (await (await LoginAsync(user.Username, user.Password)).Content.ReadFromJsonAsync<AuthResponseDto>())!;
        await AgeEmailsAsync(user.Email);
        Assert.Equal(HttpStatusCode.Accepted, (await SendResetCodeAsync(user.Email)).StatusCode);
        var newPassword = ApiFixture.NewPassword();

        var reset = await ResetAsync(user.Email, api.Emails.LastCode(user.Email), newPassword);

        Assert.Equal(HttpStatusCode.OK, reset.StatusCode);
        await (await LoginAsync(user.Email, user.Password)).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidCredentials");
        Assert.Equal(HttpStatusCode.OK, (await LoginAsync(user.Email, newPassword)).StatusCode);
        var oldRefresh = await api.CreateClient().PostAsJsonAsync("/api/auth/refresh", new { refreshToken = oldLogin.RefreshToken });
        await oldRefresh.AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidRefreshToken");
    }

    // ---------------------------------------------------------------- email change

    [Fact]
    public async Task The_profile_shows_the_email()
    {
        var user = await api.RegisterUserAsync();

        var profile = await user.Client.GetFromJsonAsync<ProfileDto>("/api/profile/me");

        Assert.Equal(user.Email, profile!.Email);
    }

    [Fact]
    public async Task An_email_change_needs_the_password()
    {
        var user = await api.RegisterUserAsync();

        var response = await user.Client.PostAsJsonAsync("/api/profile/me/email/code",
            new { newEmail = ApiFixture.NewEmail(), password = "not-my-password" });

        // a wrong password while signed in must not be 401, or the app would end the session
        await response.AssertProblemAsync(HttpStatusCode.BadRequest, "WrongPassword");
    }

    [Fact]
    public async Task An_email_change_is_confirmed_by_the_code_and_the_old_address_is_told()
    {
        var user = await api.RegisterUserAsync();
        var newEmail = ApiFixture.NewEmail();

        var sent = await user.Client.PostAsJsonAsync("/api/profile/me/email/code", new { newEmail, password = user.Password });
        Assert.Equal(HttpStatusCode.Accepted, sent.StatusCode);
        await (await user.Client.PutAsJsonAsync("/api/profile/me/email", new { code = WrongCode(api.Emails.LastCode(newEmail)) }))
            .AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidEmailCode");

        var confirmed = await user.Client.PutAsJsonAsync("/api/profile/me/email", new { code = api.Emails.LastCode(newEmail) });

        Assert.Equal(HttpStatusCode.OK, confirmed.StatusCode);
        Assert.Equal(newEmail, (await confirmed.Content.ReadFromJsonAsync<ProfileDto>())!.Email);
        Assert.Equal(EmailTexts.EmailChanged(newEmail, "en"), api.Emails.To(user.Email)[^1]);
        Assert.Equal(HttpStatusCode.OK, (await LoginAsync(newEmail, user.Password)).StatusCode);
        await (await LoginAsync(user.Email, user.Password)).AssertProblemAsync(HttpStatusCode.Unauthorized, "InvalidCredentials");
    }

    [Fact]
    public async Task A_taken_address_gets_no_code_and_the_change_cannot_be_confirmed()
    {
        var user = await api.RegisterUserAsync();
        var other = await api.RegisterUserAsync();
        await AgeEmailsAsync(other.Email);
        var before = api.Emails.To(other.Email).Count;

        var sent = await user.Client.PostAsJsonAsync("/api/profile/me/email/code", new { newEmail = other.Email, password = user.Password });

        Assert.Equal(HttpStatusCode.Accepted, sent.StatusCode);
        Assert.Equal(before, api.Emails.To(other.Email).Count);
        await (await user.Client.PutAsJsonAsync("/api/profile/me/email", new { code = "123456" }))
            .AssertProblemAsync(HttpStatusCode.BadRequest, "InvalidEmailCode");
    }
}
