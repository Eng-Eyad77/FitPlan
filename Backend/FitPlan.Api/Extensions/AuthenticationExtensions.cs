
using System.Security.Claims;
using System.Text;
using FitPlan.Api.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace FitPlan.Api.Extensions;

public static class AuthenticationExtensions
{
    public static IServiceCollection AddAuthenticationServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = configuration["Jwt:Issuer"],

                    ValidateAudience = true,
                    ValidAudience = configuration["Jwt:Audience"],

                    ValidateLifetime = true,

                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(configuration["Jwt:Key"]!)
                    ),

                    ValidateIssuerSigningKey = true
                };

                // A deleted account's token is still signed and unexpired, so it must stop here.
                // Only routes that need a login check, because they read the database anyway. Open
                // routes such as the exercise library skip it, so browsing never wakes the database.
                options.Events = new JwtBearerEvents
                {
                    OnTokenValidated = async context =>
                    {
                        var endpoint = context.HttpContext.GetEndpoint();
                        if (endpoint?.Metadata.GetMetadata<IAuthorizeData>() is null
                            || endpoint.Metadata.GetMetadata<IAllowAnonymous>() is not null)
                        {
                            return;
                        }

                        var id = context.Principal?.FindFirstValue(ClaimTypes.NameIdentifier);
                        var database = context.HttpContext.RequestServices.GetRequiredService<FitPlanDbContext>();
                        if (!Guid.TryParse(id, out var userId) || !await database.Users.AnyAsync(u => u.Id == userId))
                        {
                            context.Fail("The account no longer exists.");
                        }
                    }
                };
            });

        services.AddAuthorization();

        return services;
    }
}
