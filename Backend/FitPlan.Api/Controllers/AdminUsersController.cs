using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.DTOs.Common;
using FitPlan.Api.Extensions;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Admin;
using FitPlan.Api.Services.Profile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Controllers;

// Phase 12B: find users and act on their accounts. Every action is written to the audit log.
// Passwords are never read here, and emails come masked unless revealed (also logged).
[Route("api/admin/users")]
[Authorize(Policy = AuthenticationExtensions.AdminPolicy)]
public class AdminUsersController(FitPlanDbContext context, IProfileService profiles, TimeProvider time) : ApiControllerBase
{
    // status: all, active or disabled. search matches part of the username or the email.
    [HttpGet]
    public async Task<IActionResult> List(string? search, string status = "all", int page = 1, int pageSize = 25)
    {
        page = Math.Max(page, 1);
        pageSize = Math.Clamp(pageSize, 1, 100);

        var users = context.Users.AsQueryable();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var text = search.Trim().ToLowerInvariant();
            users = users.Where(u => u.Username.Contains(text) || u.Email.Contains(text));
        }

        users = status switch
        {
            "active" => users.Where(u => u.DisabledAt == null),
            "disabled" => users.Where(u => u.DisabledAt != null),
            _ => users
        };

        var total = await users.CountAsync();
        var rows = await users
            .OrderByDescending(u => u.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(u => new
            {
                u.Id,
                u.Username,
                u.Email,
                u.CreatedAt,
                LastWorkoutAt = context.WorkoutSessions.Where(s => s.UserId == u.Id).Max(s => (DateTime?)s.StartedAt),
                Disabled = u.DisabledAt != null,
                IsAdmin = context.AdminAccounts.Any(a => a.UserId == u.Id)
            })
            .ToArrayAsync();

        return Ok(new PagedResponseDto<AdminUserRowDto>
        {
            Items = [.. rows.Select(r => new AdminUserRowDto(r.Id, r.Username, Mask(r.Email), r.CreatedAt, r.LastWorkoutAt, r.Disabled, r.IsAdmin))],
            Page = page,
            PageSize = pageSize,
            TotalCount = total,
            TotalPages = (total + pageSize - 1) / pageSize
        });
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id)
    {
        var now = time.GetUtcNow().UtcDateTime;
        var user = await context.Users
            .Where(u => u.Id == id)
            .Select(u => new
            {
                u.Id,
                u.Username,
                u.Email,
                u.CreatedAt,
                u.DisabledAt,
                IsAdmin = context.AdminAccounts.Any(a => a.UserId == u.Id),
                Workouts = context.WorkoutSessions.Count(s => s.UserId == u.Id),
                Plans = context.WorkoutPlans.Count(p => p.UserId == u.Id),
                // one login family per signed-in device
                Devices = context.RefreshTokens
                    .Where(t => t.UserId == u.Id && t.RevokedAt == null && t.ExpiresAt > now)
                    .Select(t => t.FamilyId).Distinct().Count(),
                Reports = context.ProblemReports.Count(r => r.UserId == u.Id),
                LastWorkoutAt = context.WorkoutSessions.Where(s => s.UserId == u.Id).Max(s => (DateTime?)s.StartedAt)
            })
            .FirstOrDefaultAsync();

        if (user is null)
        {
            return Problem(Errors.UserNotFound);
        }

        return Ok(new AdminUserDetailDto(user.Id, user.Username, Mask(user.Email), user.CreatedAt, user.DisabledAt,
            user.IsAdmin, user.Workouts, user.Plans, user.Devices, user.Reports, user.LastWorkoutAt));
    }

    [HttpPost("{id:guid}/reveal-email")]
    public Task<IActionResult> RevealEmail(Guid id) =>
        ActAsync(id, "Showed email", user => Task.FromResult<IActionResult>(Ok(new AdminUserEmailDto(user.Email))));

    // Also ends every login, and the API refuses the user's current token at once.
    [HttpPost("{id:guid}/disable")]
    public Task<IActionResult> Disable(Guid id) =>
        ActAsync(id, "Disabled account", async user =>
        {
            if (await IsAdminAsync(user.Id))
            {
                return Problem(Errors.AdminAccountProtected);
            }

            var now = time.GetUtcNow().UtcDateTime;
            user.DisabledAt ??= now;
            await RevokeLoginsAsync(user.Id, now);
            return NoContent();
        });

    [HttpPost("{id:guid}/enable")]
    public Task<IActionResult> Enable(Guid id) =>
        ActAsync(id, "Enabled account", user =>
        {
            user.DisabledAt = null;
            return Task.FromResult<IActionResult>(NoContent());
        });

    // Signs the user out on every device. Their current access token still works until it expires
    // (at most Jwt:ExpirationInMinutes); disabling is the way to stop them at once.
    [HttpPost("{id:guid}/end-sessions")]
    public Task<IActionResult> EndSessions(Guid id) =>
        ActAsync(id, "Ended all sessions", async user =>
        {
            await RevokeLoginsAsync(user.Id, time.GetUtcNow().UtcDateTime);
            return NoContent();
        });

    // Permanent: removes the account and everything it owns (F-02). The audit entry stays.
    [HttpPost("{id:guid}/delete")]
    public Task<IActionResult> Delete(Guid id, AdminDeleteUserDto request) =>
        ActAsync(id, "Deleted account", async user =>
        {
            if (!string.Equals(request.Username.Trim(), user.Username, StringComparison.OrdinalIgnoreCase))
            {
                return Problem(Errors.ConfirmationMismatch);
            }

            if (await IsAdminAsync(user.Id))
            {
                return Problem(Errors.AdminAccountProtected);
            }

            await profiles.RemoveAccountAsync(user);
            return NoContent();
        });

    // Loads the user, runs the action, and logs it only when it succeeded.
    private async Task<IActionResult> ActAsync(Guid id, string action, Func<User, Task<IActionResult>> act)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == id);
        if (user is null)
        {
            return Problem(Errors.UserNotFound);
        }

        var username = user.Username;
        var result = await act(user);
        if (result is ObjectResult { StatusCode: >= 400 })
        {
            return result;
        }

        TryGetUserId(out var adminId);
        var admin = await context.Users.AsNoTracking().FirstAsync(u => u.Id == adminId);
        AdminAudit.Add(context, admin, action, username, time.GetUtcNow().UtcDateTime);
        await context.SaveChangesAsync();
        return result;
    }

    private Task<bool> IsAdminAsync(Guid userId) => context.AdminAccounts.AnyAsync(a => a.UserId == userId);

    private Task RevokeLoginsAsync(Guid userId, DateTime now) =>
        context.RefreshTokens
            .Where(t => t.UserId == userId && t.RevokedAt == null)
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.RevokedAt, now));

    // "sami@gmail.com" -> "s***@gmail.com"
    internal static string Mask(string email)
    {
        var at = email.IndexOf('@');
        return at <= 0 ? "***" : email[0] + "***" + email[at..];
    }
}
