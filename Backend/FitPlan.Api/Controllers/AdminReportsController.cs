using System.Globalization;
using System.Text;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.Extensions;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Controllers;

// Phase 12F: user reports (the ones also sent to Telegram), server errors and failed sign-ins.
[Route("api/admin")]
[Authorize(Policy = AuthenticationExtensions.AdminPolicy)]
public class AdminReportsController(FitPlanDbContext context, TimeProvider time, IWebHostEnvironment environment) : ApiControllerBase
{
    public static readonly TimeSpan ErrorWindow = TimeSpan.FromHours(24);

    // filter: open (problems not done yet), suggestions (not done yet) or done
    [HttpGet("reports")]
    public async Task<IActionResult> List(string filter = "open", int page = 1, int pageSize = 25)
    {
        page = Math.Max(page, 1);
        pageSize = Math.Clamp(pageSize, 1, 100);

        var counts = new AdminReportCountsDto(
            await context.ProblemReports.CountAsync(r => r.DoneAt == null && !r.IsSuggestion),
            await context.ProblemReports.CountAsync(r => r.DoneAt == null && r.IsSuggestion),
            await context.ProblemReports.CountAsync(r => r.DoneAt != null));

        var reports = filter switch
        {
            "suggestions" => context.ProblemReports.Where(r => r.DoneAt == null && r.IsSuggestion),
            "done" => context.ProblemReports.Where(r => r.DoneAt != null),
            _ => context.ProblemReports.Where(r => r.DoneAt == null && !r.IsSuggestion)
        };

        var total = await reports.CountAsync();
        var items = await Rows(reports.OrderByDescending(r => r.CreatedAt).Skip((page - 1) * pageSize).Take(pageSize)).ToListAsync();
        return Ok(new AdminReportListDto(items, page, (total + pageSize - 1) / pageSize, counts));
    }

    [HttpPost("reports/{id:int}/done")]
    public Task<IActionResult> MarkDone(int id) => SetDoneAsync(id, done: true);

    [HttpPost("reports/{id:int}/reopen")]
    public Task<IActionResult> Reopen(int id) => SetDoneAsync(id, done: false);

    // Every report, newest first. No emails, tokens or passwords; a cell that a spreadsheet would run
    // as a formula is written as text.
    [HttpGet("reports/export")]
    public async Task<IActionResult> Export()
    {
        var rows = await Rows(context.ProblemReports.OrderByDescending(r => r.CreatedAt)).ToListAsync();
        var csv = new StringBuilder("Id,Sent at (UTC),Kind,Status,Username,Platform,App version,Language,Telegram,Message\r\n");
        foreach (var r in rows)
        {
            csv.AppendJoin(',',
                r.Id.ToString(CultureInfo.InvariantCulture),
                r.CreatedAt.ToString("yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture),
                r.IsSuggestion ? "Suggestion" : "Problem",
                r.DoneAt is null ? "Open" : "Done",
                Cell(r.Username),
                Cell(r.Platform),
                Cell(r.AppVersion),
                Cell(r.Language),
                r.SentToTelegram ? "Sent" : "Failed",
                Cell(r.Message));
            csv.Append("\r\n");
        }

        await AuditAsync("Exported reports", $"{rows.Count} reports");
        // with a byte order mark, so Excel reads the Arabic correctly
        return File([.. Encoding.UTF8.GetPreamble(), .. Encoding.UTF8.GetBytes(csv.ToString())],
            "text/csv", $"fitplan-reports-{time.GetUtcNow():yyyy-MM-dd}.csv");
    }

    // API errors and failed sign-ins of the last 24 hours
    [HttpGet("errors")]
    public async Task<IActionResult> Errors()
    {
        var since = time.GetUtcNow().UtcDateTime - ErrorWindow;
        var events = context.ServerEvents.Where(e => e.CreatedAt >= since);

        var errors = await events
            .Where(e => e.Kind == ServerEventKind.ApiError)
            .OrderByDescending(e => e.CreatedAt)
            .Take(50)
            .Select(e => new AdminApiErrorDto(e.CreatedAt, e.Detail, e.Reason, e.RequestId))
            .ToListAsync();

        var signIns = await events
            .Where(e => e.Kind == ServerEventKind.FailedSignIn)
            .GroupBy(e => new { e.Detail, e.Reason })
            .Select(g => new { g.Key.Detail, g.Key.Reason, Attempts = g.Count(), LastAt = g.Max(e => e.CreatedAt) })
            .OrderByDescending(g => g.Attempts)
            .Take(50)
            .ToListAsync();

        return Ok(new AdminErrorsDto(errors, [.. signIns.Select(s => new AdminFailedSignInDto(s.Detail, s.Reason, s.Attempts, s.LastAt))]));
    }

    // Lets the admin check, outside Production, that an error shows up here with its request ID.
    [HttpPost("errors/test")]
    public IActionResult ThrowTestError()
    {
        if (environment.IsProduction())
        {
            return NotFound();
        }

        throw new InvalidOperationException("Test error started from the admin.");
    }

    private static IQueryable<AdminReportDto> Rows(IQueryable<ProblemReport> reports) =>
        reports.Select(r => new AdminReportDto(r.Id, r.User.Username, r.Message, r.IsSuggestion, r.Platform, r.AppVersion,
            r.Language, r.SentToTelegram, r.CreatedAt, r.DoneAt));

    private async Task<IActionResult> SetDoneAsync(int id, bool done)
    {
        var report = await context.ProblemReports.FirstOrDefaultAsync(r => r.Id == id);
        if (report is null)
        {
            return Problem(Common.Results.Errors.ReportNotFound);
        }

        report.DoneAt = done ? report.DoneAt ?? time.GetUtcNow().UtcDateTime : null;
        await AuditAsync(done ? "Marked report done" : "Reopened report", $"#{id}");
        return NoContent();
    }

    // saves any pending change together with the audit entry
    private async Task AuditAsync(string action, string target)
    {
        TryGetUserId(out var adminId);
        var admin = await context.Users.AsNoTracking().FirstAsync(u => u.Id == adminId);
        AdminAudit.Add(context, admin, action, target, time.GetUtcNow().UtcDateTime);
        await context.SaveChangesAsync();
    }

    // quoted; a leading = + - @ (a formula to a spreadsheet) gets an apostrophe in front
    private static string Cell(string? text)
    {
        if (string.IsNullOrEmpty(text))
        {
            return "";
        }

        if ("=+-@\t\r".Contains(text[0]))
        {
            text = "'" + text;
        }

        return "\"" + text.Replace("\"", "\"\"") + "\"";
    }
}
