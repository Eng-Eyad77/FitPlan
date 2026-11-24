using System.Net;
using System.Net.Http.Json;
using FitPlan.Api.DTOs.Reports;
using FitPlan.Api.Extensions;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 11.5D (D14): problem reports are saved, then sent to the owner on Telegram.
[Collection(ApiCollection.Name)]
public class ReportTests(ApiFixture api)
{
    private static object Report(string message = "Finishing a workout freezes the app.") =>
        new { message, appVersion = "1.0.3", platform = "ios" };

    [Fact]
    public async Task A_report_is_saved_and_sent_to_Telegram_without_the_email()
    {
        var user = await api.RegisterUserAsync();
        user.Client.DefaultRequestHeaders.AcceptLanguage.ParseAdd("ar");

        var response = await user.Client.PostAsJsonAsync("/api/reports", Report());

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var id = (await response.Content.ReadFromJsonAsync<ProblemReportCreatedDto>())!.Id;
        var saved = await api.WithDbContextAsync(c => c.ProblemReports.SingleAsync(r => r.Id == id));
        Assert.Equal(user.Id, saved.UserId);
        Assert.Equal("ar", saved.Language);
        Assert.True(saved.SentToTelegram);

        var text = Assert.Single(api.Telegram.Sent, t => t.Contains($"#{id}\n"));
        Assert.Contains(user.Username, text);
        Assert.Contains("1.0.3 · ios · ar", text);
        Assert.Contains("Finishing a workout freezes the app.", text);
        Assert.DoesNotContain(user.Email, text);
    }

    [Fact]
    public async Task A_report_is_kept_when_Telegram_fails()
    {
        var user = await api.RegisterUserAsync();
        api.Telegram.Fail = true;
        try
        {
            var response = await user.Client.PostAsJsonAsync("/api/reports", Report());

            Assert.Equal(HttpStatusCode.Created, response.StatusCode);
            var id = (await response.Content.ReadFromJsonAsync<ProblemReportCreatedDto>())!.Id;
            Assert.False(await api.WithDbContextAsync(c => c.ProblemReports.Where(r => r.Id == id).Select(r => r.SentToTelegram).SingleAsync()));
        }
        finally
        {
            api.Telegram.Fail = false;
        }
    }

    [Fact]
    public async Task Reports_need_sign_in()
    {
        var response = await api.CreateClient().PostAsJsonAsync("/api/reports", Report());

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Theory]
    [InlineData("too short")]
    [InlineData("")]
    public async Task A_message_needs_10_to_2000_characters(string message)
    {
        var user = await api.RegisterUserAsync();

        var tooShort = await user.Client.PostAsJsonAsync("/api/reports", Report(message));
        var tooLong = await user.Client.PostAsJsonAsync("/api/reports", Report(new string('x', 2001)));

        await tooShort.AssertProblemAsync(HttpStatusCode.BadRequest, "ValidationFailed");
        await tooLong.AssertProblemAsync(HttpStatusCode.BadRequest, "ValidationFailed");
    }

    [Fact]
    public async Task Each_user_gets_a_few_reports_an_hour()
    {
        var user = await api.RegisterUserAsync();
        for (var i = 0; i < RateLimitingExtensions.ReportsPermitPerHour; i++)
        {
            Assert.Equal(HttpStatusCode.Created, (await user.Client.PostAsJsonAsync("/api/reports", Report())).StatusCode);
        }

        var limited = await user.Client.PostAsJsonAsync("/api/reports", Report());

        await limited.AssertProblemAsync(HttpStatusCode.TooManyRequests, "TooManyRequests");
        // another user is not affected
        var other = await api.RegisterUserAsync();
        Assert.Equal(HttpStatusCode.Created, (await other.Client.PostAsJsonAsync("/api/reports", Report())).StatusCode);
    }

    [Fact]
    public async Task Deleting_the_account_deletes_its_reports()
    {
        var user = await api.RegisterUserAsync();
        await user.Client.PostAsJsonAsync("/api/reports", Report());

        (await user.Client.PostAsJsonAsync("/api/profile/me/delete", new { password = user.Password })).EnsureSuccessStatusCode();

        Assert.False(await api.WithDbContextAsync(c => c.ProblemReports.AnyAsync(r => r.UserId == user.Id)));
    }
}
