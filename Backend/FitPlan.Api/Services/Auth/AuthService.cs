using System.Security.Cryptography;
using System.Text;
using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Admin;
using FitPlan.Api.Services.Email;
using FitPlan.Api.DTOs.Admin;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace FitPlan.Api.Services.Auth;

public class AuthService(FitPlanDbContext context, IConfiguration configuration, TimeProvider time, EmailCodeService emailCodes) : IAuthService
{
    // A phone can lose the response to a refresh and send the same token again. Inside this window
    // that isn't treated as theft: a second new token is issued and the family stays valid.
    public const string AdminClaim = "fitplan_admin";

    public static readonly TimeSpan ReuseGrace = TimeSpan.FromSeconds(30);

    private TimeSpan RefreshLifetime =>
        TimeSpan.FromDays(configuration.GetValue<int?>("Jwt:RefreshTokenDays") is > 0 and var days ? days : 30);

    // Admin sessions are short and can't be refreshed: after an hour the admin signs in again with a new code.
    public static readonly TimeSpan AdminSessionLifetime = TimeSpan.FromHours(1);

    private string GenerateAccessToken(User user, AdminRole? adminRole = null)
    {
        var issuer = configuration["Jwt:Issuer"];
        var audience = configuration["Jwt:Audience"];
        var key = configuration["Jwt:Key"];
        var expirationInMinutes = adminRole is null
            ? configuration.GetValue<int>("Jwt:ExpirationInMinutes")
            : (int)AdminSessionLifetime.TotalMinutes;

        if (string.IsNullOrWhiteSpace(issuer) || string.IsNullOrWhiteSpace(audience) || string.IsNullOrWhiteSpace(key) || expirationInMinutes <= 0)
        {
            throw new InvalidOperationException("JWT configuration is missing.");
        }

        var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));

        var signingCredentials = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha512);

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString())
        };

        // only tokens from the admin sign-in carry it, so the phone app's tokens never open /api/admin
        if (adminRole is { } role)
        {
            claims.Add(new Claim(AdminClaim, role.ToString()));
        }

        var tokenDescriptor = new JwtSecurityToken
        (
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expirationInMinutes),
            signingCredentials: signingCredentials
        );

        return new JwtSecurityTokenHandler().WriteToken(tokenDescriptor);
    }


    public async Task<Result<bool>> SendSignUpCodeAsync(string email, string language)
    {
        email = EmailCodeService.Normalize(email);
        if (await context.Users.AnyAsync(u => u.Email == email))
        {
            return Result<bool>.Failure(Errors.EmailAlreadyExists);
        }

        return await emailCodes.SendAsync(email, EmailCodePurpose.SignUp, null, language);
    }

    public async Task<Result<AuthResponseDto>> RegisterAsync(RegisterRequestDto request)
    {
        var email = EmailCodeService.Normalize(request.Email);

        // checked before the code, so a taken username doesn't use the code up
        if (await context.Users.AnyAsync(u => u.Username == request.Username))
        {
            return Result<AuthResponseDto>.Failure(Errors.UsernameAlreadyExists);
        }

        if (await emailCodes.UseAsync(EmailCodePurpose.SignUp, email, null, request.Code) is null)
        {
            return Result<AuthResponseDto>.Failure(Errors.InvalidEmailCode);
        }

        var now = time.GetUtcNow().UtcDateTime;
        var user = new User
        {
            Id = Guid.NewGuid(),
            Username = request.Username,
            Email = email,
            CreatedAt = now,
            UpdatedAt = now,
            PasswordHash = string.Empty
        };

        user.PasswordHash = new PasswordHasher<User>().HashPassword(user, request.Password);

        context.Users.Add(user);

        // Handles a registered email and two concurrent sign-ups (unique indexes on Username and Email).
        try
        {
            await context.SaveChangesAsync();
        }
        catch (DbUpdateException ex) when (ex.IsUniqueConstraintViolation())
        {
            context.ChangeTracker.Clear();
            return Result<AuthResponseDto>.Failure(await context.Users.AnyAsync(u => u.Email == email)
                ? Errors.EmailAlreadyExists
                : Errors.UsernameAlreadyExists);
        }

        return Result<AuthResponseDto>.Success(await IssueAsync(user, Guid.NewGuid()));
    }

    public async Task<Result<bool>> SendPasswordResetCodeAsync(string email, string language)
    {
        email = EmailCodeService.Normalize(email);
        var userId = await context.Users.Where(u => u.Email == email).Select(u => (Guid?)u.Id).FirstOrDefaultAsync();
        if (userId is null)
        {
            return Result<bool>.Failure(Errors.EmailNotRegistered);
        }

        return await emailCodes.SendAsync(email, EmailCodePurpose.ResetPassword, userId, language);
    }

    // Checks the emailed code without using it up, so the app can ask for the new password next.
    // Each check counts as an attempt, like the reset itself.
    public async Task<Result<bool>> CheckPasswordResetCodeAsync(ResetCodeCheckDto request)
    {
        var email = EmailCodeService.Normalize(request.Email);
        var valid = await context.Users.AnyAsync(u => u.Email == email) &&
            await emailCodes.UseAsync(EmailCodePurpose.ResetPassword, email, null, request.Code, consume: false) is not null;

        return valid ? Result<bool>.Success(true) : Result<bool>.Failure(Errors.InvalidEmailCode);
    }

    // A forgotten password: the emailed code proves who it is. Every other login of the user ends,
    // and the user is signed in with the new password.
    public async Task<Result<AuthResponseDto>> ResetPasswordAsync(ResetPasswordRequestDto request)
    {
        var email = EmailCodeService.Normalize(request.Email);
        var user = await context.Users.FirstOrDefaultAsync(u => u.Email == email);

        if (user is null || await emailCodes.UseAsync(EmailCodePurpose.ResetPassword, email, null, request.Code) is null)
        {
            return Result<AuthResponseDto>.Failure(Errors.InvalidEmailCode);
        }

        var now = time.GetUtcNow().UtcDateTime;
        user.PasswordHash = new PasswordHasher<User>().HashPassword(user, request.NewPassword);
        user.UpdatedAt = now;
        await context.SaveChangesAsync();

        await context.RefreshTokens
            .Where(t => t.UserId == user.Id && t.RevokedAt == null)
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.RevokedAt, now));

        return Result<AuthResponseDto>.Success(await IssueAsync(user, Guid.NewGuid()));
    }

    // Usernames can't contain "@", so an "@" means an email.
    public async Task<Result<AuthResponseDto>> LoginAsync(LoginRequestDto request)
    {
        var login = request.Login.Trim();
        var email = EmailCodeService.Normalize(login);
        var user = login.Contains('@')
            ? await context.Users.FirstOrDefaultAsync(u => u.Email == email)
            : await context.Users.FirstOrDefaultAsync(u => u.Username == login);

        if (user is null ||
            new PasswordHasher<User>().VerifyHashedPassword(user, user.PasswordHash, request.Password) == PasswordVerificationResult.Failed)
        {
            return Result<AuthResponseDto>.Failure(Errors.InvalidCredentials);
        }

        return Result<AuthResponseDto>.Success(await IssueAsync(user, Guid.NewGuid()));
    }

    // Phase 12: the password and the authenticator code, both checked before anything is said.
    public async Task<Result<AdminSignInResponseDto>> AdminLoginAsync(AdminLoginRequestDto request)
    {
        var login = request.Login.Trim();
        var email = EmailCodeService.Normalize(login);
        var user = login.Contains('@')
            ? await context.Users.FirstOrDefaultAsync(u => u.Email == email)
            : await context.Users.FirstOrDefaultAsync(u => u.Username == login);
        var admin = user is null ? null : await context.AdminAccounts.FirstOrDefaultAsync(a => a.UserId == user.Id);

        var now = time.GetUtcNow();
        if (user is null || admin is null ||
            new PasswordHasher<User>().VerifyHashedPassword(user, user.PasswordHash, request.Password) == PasswordVerificationResult.Failed ||
            Totp.Match(admin.TotpSecret, request.Code.Trim(), now, admin.LastTotpStep) is not { } step)
        {
            return Result<AdminSignInResponseDto>.Failure(Errors.InvalidAdminSignIn);
        }

        admin.LastTotpStep = step;
        AdminAudit.Add(context, user, "Signed in", null, now.UtcDateTime);

        // two sign-ins racing with the same code: only the first one saves
        try
        {
            await context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            return Result<AdminSignInResponseDto>.Failure(Errors.InvalidAdminSignIn);
        }

        return Result<AdminSignInResponseDto>.Success(new AdminSignInResponseDto(
            user.Username, admin.Role, GenerateAccessToken(user, admin.Role), now.UtcDateTime + AdminSessionLifetime));
    }

    public async Task<Result<AuthResponseDto>> RefreshAsync(string refreshToken)
    {
        var now = time.GetUtcNow().UtcDateTime;
        var stored = await context.RefreshTokens
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.TokenHash == Hash(refreshToken));

        if (stored is null || stored.RevokedAt is not null || stored.ExpiresAt <= now)
        {
            return Result<AuthResponseDto>.Failure(Errors.InvalidRefreshToken);
        }

        if (stored.UsedAt is { } usedAt && now - usedAt > ReuseGrace)
        {
            // An old token came back: someone may have copied it, so the whole login ends.
            await RevokeFamilyAsync(stored.FamilyId, now);
            return Result<AuthResponseDto>.Failure(Errors.InvalidRefreshToken);
        }

        stored.UsedAt ??= now;
        return Result<AuthResponseDto>.Success(await IssueAsync(stored.User, stored.FamilyId));
    }

    // Ends the login the token belongs to. An unknown token is ignored, so the answer reveals nothing.
    public async Task LogoutAsync(string refreshToken)
    {
        var familyId = await context.RefreshTokens
            .Where(t => t.TokenHash == Hash(refreshToken))
            .Select(t => (Guid?)t.FamilyId)
            .FirstOrDefaultAsync();

        if (familyId is { } id)
        {
            await RevokeFamilyAsync(id, time.GetUtcNow().UtcDateTime);
        }
    }

    private async Task<AuthResponseDto> IssueAsync(User user, Guid familyId)
    {
        var now = time.GetUtcNow().UtcDateTime;
        var token = Base64UrlEncoder.Encode(RandomNumberGenerator.GetBytes(32));
        var expiresAt = now + RefreshLifetime;

        context.RefreshTokens.Add(new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            FamilyId = familyId,
            TokenHash = Hash(token),
            CreatedAt = now,
            ExpiresAt = expiresAt
        });
        await context.SaveChangesAsync();

        // tokens nobody can use any more are only clutter
        await context.RefreshTokens
            .Where(t => t.UserId == user.Id && t.ExpiresAt <= now)
            .ExecuteDeleteAsync();

        return new AuthResponseDto(user.Id, user.Username, GenerateAccessToken(user), token, expiresAt);
    }

    private Task RevokeFamilyAsync(Guid familyId, DateTime now) =>
        context.RefreshTokens
            .Where(t => t.FamilyId == familyId && t.RevokedAt == null)
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.RevokedAt, now));

    private static string Hash(string token) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)));
}
