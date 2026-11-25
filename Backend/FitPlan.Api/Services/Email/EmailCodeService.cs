using System.Security.Cryptography;
using System.Text;
using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.Email;

// 6-digit codes for sign-up, password reset and email change (D18). A code lives 10 minutes, works once
// and locks after 5 tries. Each address gets at most one email a minute and 5 an hour.
public class EmailCodeService(FitPlanDbContext context, IEmailSender sender, TimeProvider time)
{
    public static readonly TimeSpan Lifetime = TimeSpan.FromMinutes(10);
    public static readonly TimeSpan MinGap = TimeSpan.FromMinutes(1);
    public const int MaxAttempts = 5;
    public const int MaxPerHour = 5;

    public static string Normalize(string email) => email.Trim().ToLowerInvariant();

    // The callers check first that the address may get this code (D18 revised 2026-11-25: the app says
    // plainly when an email is or isn't registered; the quotas still limit how fast anyone can ask).
    public async Task<Result<bool>> SendAsync(string email, EmailCodePurpose purpose, Guid? userId, string language)
    {
        var now = time.GetUtcNow().UtcDateTime;

        var recent = await context.EmailCodes
            .Where(c => c.Email == email && c.CreatedAt > now.AddHours(-1))
            .Select(c => c.CreatedAt)
            .ToListAsync();

        if (recent.Count >= MaxPerHour || recent.Any(t => t > now - MinGap))
        {
            return Result<bool>.Failure(Errors.TooManyEmails);
        }

        // rows older than a day count for nothing any more
        await context.EmailCodes.Where(c => c.CreatedAt < now.AddDays(-1)).ExecuteDeleteAsync();

        var code = RandomNumberGenerator.GetInt32(1_000_000).ToString("D6");
        var entry = new EmailCode
        {
            Id = Guid.NewGuid(),
            Email = email,
            Purpose = purpose,
            UserId = userId,
            CodeHash = string.Empty,
            CreatedAt = now,
            ExpiresAt = now + Lifetime
        };
        entry.CodeHash = Hash(entry.Id, code);

        context.EmailCodes.Add(entry);
        await context.SaveChangesAsync();

        return await sender.SendAsync(email, EmailTexts.Code(purpose, code, language))
            ? Result<bool>.Success(true)
            : Result<bool>.Failure(Errors.EmailNotSent);
    }

    // Uses the newest code for the address (or, for ChangeEmail, the user) and returns its address,
    // or null if it is wrong, expired, used or locked. Both updates are atomic, so parallel guesses
    // can't get past the try limit and a code can't be used twice.
    public async Task<string?> UseAsync(EmailCodePurpose purpose, string? email, Guid? userId, string code, bool consume = true)
    {
        var now = time.GetUtcNow().UtcDateTime;

        var entry = await context.EmailCodes
            .Where(c => c.Purpose == purpose && (email == null || c.Email == email) && (userId == null || c.UserId == userId))
            .OrderByDescending(c => c.CreatedAt)
            .FirstOrDefaultAsync();

        if (entry is null || entry.UsedAt is not null || entry.ExpiresAt <= now)
        {
            return null;
        }

        var counted = await context.EmailCodes
            .Where(c => c.Id == entry.Id && c.Attempts < MaxAttempts)
            .ExecuteUpdateAsync(s => s.SetProperty(c => c.Attempts, c => c.Attempts + 1));

        if (counted == 0 || !Matches(entry, code))
        {
            return null;
        }

        if (!consume)
        {
            return entry.Email;
        }

        var used = await context.EmailCodes
            .Where(c => c.Id == entry.Id && c.UsedAt == null)
            .ExecuteUpdateAsync(s => s.SetProperty(c => c.UsedAt, now));

        return used == 1 ? entry.Email : null;
    }

    public Task<bool> NotifyAsync(string email, EmailText text) => sender.SendAsync(email, text);

    private static bool Matches(EmailCode entry, string code) =>
        entry.CodeHash.Length > 0 &&
        CryptographicOperations.FixedTimeEquals(
            Encoding.ASCII.GetBytes(entry.CodeHash), Encoding.ASCII.GetBytes(Hash(entry.Id, code.Trim())));

    // shortcut: a fast hash, so a stolen database would reveal live codes; they last 10 minutes, so that's accepted
    private static string Hash(Guid id, string code) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"{id:N}:{code}")));
}
