using FitPlan.Api.Data;
using FitPlan.Api.Models;

namespace FitPlan.Api.Services.Admin;

// Every admin action goes through here, saved with the change it describes.
public static class AdminAudit
{
    public static void Add(FitPlanDbContext context, User admin, string action, string? target, DateTime now) =>
        context.AdminAuditEntries.Add(new AdminAuditEntry
        {
            AdminUserId = admin.Id,
            AdminName = admin.Username,
            Action = action,
            Target = target,
            CreatedAt = now
        });
}
