using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 12F: user reports, API errors and failed sign-ins in the admin.
[Collection(ApiCollection.Name)]
public class AdminReportsTests(ApiFixture api)
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    [Fact]
    public async Task A_normal_user_cant_reach_reports_or_errors()
    {
        var user = await api.RegisterUserAsync();

        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.GetAsync("/api/admin/reports")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.GetAsync("/api/admin/reports/export")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.PostAsync("/api/admin/reports/1/done", null)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.GetAsync("/api/admin/errors")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await user.Client.PostAsync("/api/admin/errors/test", null)).StatusCode);
    }

    [Fact]
    public async Task A_report_moves_from_open_to_done_and_back_and_each_step_is_logged()
    {
        var (owner, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();
        var id = await ReportAsync(user, "The rest timer stops when I lock the screen.");

        var open = await ListAsync(admin, "open");
        var shown = Assert.Single(open.Items, r => r.Id == id);
        Assert.Equal(user.Username, shown.Username);
        Assert.Null(shown.DoneAt);

        Assert.Equal(HttpStatusCode.NoContent, (await admin.PostAsync($"/api/admin/reports/{id}/done", null)).StatusCode);
        var done = await ListAsync(admin, "done");
        Assert.Contains(done.Items, r => r.Id == id && r.DoneAt != null);
        Assert.DoesNotContain((await ListAsync(admin, "open")).Items, r => r.Id == id);
        Assert.Equal(open.Counts.Open - 1, done.Counts.Open);

        Assert.Equal(HttpStatusCode.NoContent, (await admin.PostAsync($"/api/admin/reports/{id}/reopen", null)).StatusCode);
        Assert.Contains((await ListAsync(admin, "open")).Items, r => r.Id == id);
        Assert.True(await LoggedAsync(owner.Id, "Marked report done", $"#{id}"));
        Assert.True(await LoggedAsync(owner.Id, "Reopened report", $"#{id}"));

        await (await admin.PostAsync("/api/admin/reports/999999/done", null)).AssertProblemAsync(HttpStatusCode.NotFound, "ReportNotFound");
    }

    [Fact]
    public async Task Suggestions_are_listed_apart_from_problems()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();
        var response = await user.Client.PostAsJsonAsync("/api/reports",
            new { message = "A dark and light theme switch would be nice.", platform = "ios", isSuggestion = true });
        var id = JsonDocument.Parse(await response.Content.ReadAsStringAsync()).RootElement.GetProperty("id").GetInt32();

        Assert.Contains((await ListAsync(admin, "suggestions")).Items, r => r.Id == id && r.IsSuggestion);
        Assert.DoesNotContain((await ListAsync(admin, "open")).Items, r => r.Id == id);
    }

    [Fact]
    public async Task The_export_has_no_emails_and_keeps_formulas_as_text()
    {
        var (owner, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();
        await ReportAsync(user, "=HYPERLINK(\"http://example.test\",\"click\") the app is slow");

        var response = await admin.GetAsync("/api/admin/reports/export");
        var csv = await response.Content.ReadAsStringAsync();

        Assert.Equal("text/csv", response.Content.Headers.ContentType?.MediaType);
        Assert.Contains(user.Username, csv);
        Assert.Contains("\"'=HYPERLINK(\"\"http://example.test\"\"", csv);
        Assert.DoesNotContain(user.Email, csv);
        Assert.True(await api.WithDbContextAsync(c => c.AdminAuditEntries.AnyAsync(e => e.AdminUserId == owner.Id && e.Action == "Exported reports")));
    }

    [Fact]
    public async Task Failed_sign_ins_are_counted_by_account_without_what_was_typed()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var user = await api.RegisterUserAsync();
        var wrongPassword = "Wrong-" + Guid.NewGuid().ToString("N")[..10];
        for (var i = 0; i < 2; i++)
        {
            await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { login = user.Username, password = wrongPassword });
        }

        var unknown = "nobody-" + Guid.NewGuid().ToString("N")[..8] + "@example.test";
        await api.CreateClient().PostAsJsonAsync("/api/auth/login", new { login = unknown, password = wrongPassword });

        var body = await admin.GetStringAsync("/api/admin/errors");
        var errors = JsonSerializer.Deserialize<AdminErrorsDto>(body, Json)!;

        Assert.Contains(errors.FailedSignIns, s => s.Account == user.Username && s.Reason == "Wrong password" && s.Attempts == 2);
        Assert.Contains(errors.FailedSignIns, s => s.Account == "Unknown account" && s.Reason == "No such account");
        Assert.DoesNotContain(wrongPassword, body);
        Assert.DoesNotContain(unknown, body);
    }

    [Fact]
    public async Task A_test_error_shows_up_with_the_request_id_the_caller_got()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();

        var failed = await admin.PostAsync("/api/admin/errors/test", null);
        Assert.Equal(HttpStatusCode.InternalServerError, failed.StatusCode);
        var traceId = JsonDocument.Parse(await failed.Content.ReadAsStringAsync()).RootElement.GetProperty("traceId").GetString();

        var errors = await admin.GetFromJsonAsync<AdminErrorsDto>("/api/admin/errors", Json);
        var shown = Assert.Single(errors!.ApiErrors, e => e.RequestId == traceId);
        Assert.Equal("POST /api/admin/errors/test", shown.Endpoint);
        Assert.Equal("InvalidOperationException", shown.Error);
    }

    [Fact]
    public async Task The_overview_counts_open_problems_only()
    {
        var (_, admin) = await api.SignInAsOwnerAsync();
        var before = (await admin.GetFromJsonAsync<AdminOverviewDto>("/api/admin/overview?refresh=true", Json))!.OpenReports;
        var user = await api.RegisterUserAsync();
        var id = await ReportAsync(user, "The squat demo doesn't load on mobile data.");

        Assert.Equal(before + 1, (await admin.GetFromJsonAsync<AdminOverviewDto>("/api/admin/overview?refresh=true", Json))!.OpenReports);
        await admin.PostAsync($"/api/admin/reports/{id}/done", null);
        Assert.Equal(before, (await admin.GetFromJsonAsync<AdminOverviewDto>("/api/admin/overview?refresh=true", Json))!.OpenReports);
    }

    private static async Task<int> ReportAsync(TestUser user, string message)
    {
        var response = await user.Client.PostAsJsonAsync("/api/reports", new { message, appVersion = "1.0.3", platform = "ios" });
        response.EnsureSuccessStatusCode();
        return JsonDocument.Parse(await response.Content.ReadAsStringAsync()).RootElement.GetProperty("id").GetInt32();
    }

    // newest first, so a report just sent is on the first page
    private static async Task<AdminReportListDto> ListAsync(HttpClient admin, string filter) =>
        (await admin.GetFromJsonAsync<AdminReportListDto>($"/api/admin/reports?filter={filter}&pageSize=100", Json))!;

    private Task<bool> LoggedAsync(Guid adminId, string action, string target) =>
        api.WithDbContextAsync(c => c.AdminAuditEntries.AnyAsync(e => e.AdminUserId == adminId && e.Action == action && e.Target == target));
}
