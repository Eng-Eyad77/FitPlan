using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Admin;
using FitPlan.Api.DTOs.Common;
using FitPlan.Api.Extensions;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Controllers;

// Phase 12. Everything here needs an admin token, except the sign-in that gives one.
[Route("api/admin")]
[Authorize(Policy = AuthenticationExtensions.AdminPolicy)]
public class AdminController(IAuthService authService, FitPlanDbContext context) : ApiControllerBase
{
    [HttpPost("auth/login")]
    [AllowAnonymous]
    [EnableRateLimiting(RateLimitingExtensions.SignInPolicy)]
    public async Task<IActionResult> Login(AdminLoginRequestDto request)
    {
        var result = await authService.AdminLoginAsync(request);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }

    [HttpGet("me")]
    public async Task<IActionResult> Me()
    {
        TryGetUserId(out var userId);
        var me = await context.AdminAccounts
            .Where(a => a.UserId == userId)
            .Select(a => new AdminMeDto(a.User.Username, a.Role))
            .SingleAsync();

        return Ok(me);
    }

    // Newest first.
    [HttpGet("audit")]
    public async Task<IActionResult> Audit(int page = 1, int pageSize = 50)
    {
        page = Math.Max(page, 1);
        pageSize = Math.Clamp(pageSize, 1, 100);

        var total = await context.AdminAuditEntries.CountAsync();
        var items = await context.AdminAuditEntries
            .OrderByDescending(e => e.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(e => new AdminAuditEntryDto(e.Id, e.AdminName, e.Action, e.Target, e.CreatedAt))
            .ToArrayAsync();

        return Ok(new PagedResponseDto<AdminAuditEntryDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            TotalCount = total,
            TotalPages = (total + pageSize - 1) / pageSize
        });
    }
}
