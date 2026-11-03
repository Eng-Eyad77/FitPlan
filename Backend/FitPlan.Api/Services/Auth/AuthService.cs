using System.Text;
using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace FitPlan.Api.Services.Auth;

public class AuthService(FitPlanDbContext context, IConfiguration configuration) : IAuthService
{

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
        catch (DbUpdateException ex) when (
            ex.InnerException is SqlException sqlException &&
            (sqlException.Number == 2601 || sqlException.Number == 2627))
        {
            return Result<AuthResponseDto>.Failure(Errors.UsernameAlreadyExists);
        }

        var authResponse = new AuthResponseDto(user.Id, user.Username, GenerateAccessToken(user));

        return Result<AuthResponseDto>.Success(authResponse);
    }

    public async Task<Result<AuthResponseDto>> LoginAsync(LoginRequestDto request)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Username == request.Username);

        if (user is null ||
            new PasswordHasher<User>().VerifyHashedPassword(user, user.PasswordHash, request.Password) == PasswordVerificationResult.Failed)
        {
            return Result<AuthResponseDto>.Failure(Errors.InvalidCredentials);
        }

        var authResponse = new AuthResponseDto(user.Id, user.Username, GenerateAccessToken(user));

        return Result<AuthResponseDto>.Success(authResponse);
    }
}
