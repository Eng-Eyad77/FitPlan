using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Reports;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.Reports;

public interface IProblemReportService
{
    Task<Result<ProblemReportCreatedDto>> CreateAsync(Guid userId, CreateProblemReportDto request, string language);
}

// D14: the report is saved first, so a Telegram failure never loses it.
public class ProblemReportService(FitPlanDbContext context, ITelegramNotifier telegram, TimeProvider time) : IProblemReportService
{
    public async Task<Result<ProblemReportCreatedDto>> CreateAsync(Guid userId, CreateProblemReportDto request, string language)
    {
        var username = await context.Users.Where(u => u.Id == userId).Select(u => u.Username).FirstOrDefaultAsync();
        if (username is null)
        {
            return Result<ProblemReportCreatedDto>.Failure(Errors.UserNotFound);
        }

        var report = new ProblemReport
        {
            UserId = userId,
            Message = request.Message.Trim(),
            AppVersion = request.AppVersion?.Trim(),
            Platform = request.Platform?.Trim(),
            Language = language,
            CreatedAt = time.GetUtcNow().UtcDateTime
        };
        context.ProblemReports.Add(report);
        await context.SaveChangesAsync();

        // no email in the message: the owner looks it up by the report number
        var text = $"🐞 Report #{report.Id}\nUser: {username}\nApp: {report.AppVersion ?? "?"} · {report.Platform ?? "?"} · {language}\n───\n{report.Message}";
        if (await telegram.SendAsync(text))
        {
            report.SentToTelegram = true;
            await context.SaveChangesAsync();
        }

        return Result<ProblemReportCreatedDto>.Success(new ProblemReportCreatedDto(report.Id));
    }
}
