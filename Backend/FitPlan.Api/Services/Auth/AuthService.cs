using System.Text;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Auth;
using FitPlan.Api.Models;
using Microsoft.AspNetCore.Identity;
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

        var signingKey = new SymmetricSecurityKey
          (
              Encoding.UTF8.GetBytes(key)
          );

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

        var accessToken = new JwtSecurityTokenHandler()
       .WriteToken(tokenDescriptor);

        return accessToken;

    }





    public async Task<AuthResult> RegisterAsync(RegisterRequestDto request)
    {


        if (await context.Users.AnyAsync(u => u.Username == request.Username))
        {

            var result = new AuthResult(
                 false,
                 null,
                "UsernameAlreadyExists"
            );
            return result;
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            Username = request.Username,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            PasswordHash = string.Empty
        };
        var hashedPassword = new PasswordHasher<User>()
                                                        .HashPassword(user, request.Password);

        user.PasswordHash = hashedPassword;


        var accessToken = GenerateAccessToken(user);


        context.Users.Add(user);
        await context.SaveChangesAsync();





        var authResponse = new AuthResponseDto(
            user.Id,
            user.Username,
            accessToken
        );

        return new AuthResult(true, authResponse , null);



    }



    
}
