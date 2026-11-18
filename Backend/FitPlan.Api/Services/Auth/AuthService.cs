using System.Security.Cryptography;
using System.Text;
using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace FitPlan.Api.Services.Auth;

public class AuthService(FitPlanDbContext context, IConfiguration configuration, TimeProvider time) : IAuthService
{
    // A phone can lose the response to a refresh and send the same token again. Inside this window
    // that isn't treated as theft: a second new token is issued and the family stays valid.
    public static readonly TimeSpan ReuseGrace = TimeSpan.FromSeconds(30);

    private TimeSpan RefreshLifetime =>
        TimeSpan.FromDays(configuration.GetValue<int?>("Jwt:RefreshTokenDays") is > 0 and var days ? days : 30);

    private string GenerateAccessToken(User user)
    {
        var issuer = configuration["Jwt:Issuer"];
        var audience = configuration["Jwt:Audience"];
        var key = configuration["Jwt:Key"];
        var expirationInMinutes = configuration.GetValue<int>("Jwt:ExpirationInMinutes");

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


    public async Task<Result<AuthResponseDto>> RegisterAsync(RegisterRequestDto request)
    {
        if (await context.Users.AnyAsync(u => u.Username == request.Username))
        {
            return Result<AuthResponseDto>.Failure(Errors.UsernameAlreadyExists);
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            Username = request.Username,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            PasswordHash = string.Empty
        };

        user.PasswordHash = new PasswordHasher<User>().HashPassword(user, request.Password);

        context.Users.Add(user);

        // Handle two concurrent registrations with the same username (unique index on Username).
        try
        {
            await context.SaveChangesAsync();
        }
        catch (DbUpdateException ex) when (ex.IsUniqueConstraintViolation())
        {
            return Result<AuthResponseDto>.Failure(Errors.UsernameAlreadyExists);
        }

        return Result<AuthResponseDto>.Success(await IssueAsync(user, Guid.NewGuid()));
    }

    public async Task<Result<AuthResponseDto>> LoginAsync(LoginRequestDto request)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Username == request.Username);

        if (user is null ||
            new PasswordHasher<User>().VerifyHashedPassword(user, user.PasswordHash, request.Password) == PasswordVerificationResult.Failed)
        {
            return Result<AuthResponseDto>.Failure(Errors.InvalidCredentials);
        }

        return Result<AuthResponseDto>.Success(await IssueAsync(user, Guid.NewGuid()));
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
