
using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.WorkoutSessions;

public static class SessionGuard
{
    // Ownership + status check before changing anything inside a session:
    // the session must exist, belong to the user, and still be in progress.
    // Returns null when everything is fine, otherwise the error to return.
    public static async Task<Error?> CheckActiveSessionAsync(
        this FitPlanDbContext context,
        Guid userId,
        Guid sessionId)
    {
        var session = await context.WorkoutSessions
            .Where(s => s.Id == sessionId && s.UserId == userId)
            .Select(s => new { s.CompletedAt })
            .FirstOrDefaultAsync();

        if (session is null)
        {
            return Errors.WorkoutSessionNotFound;
        }

        if (session.CompletedAt is not null)
        {
            return Errors.SessionNotActive;
        }

        return null;
    }
}
