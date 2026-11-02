
using FitPlan.Api.Data;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Extensions;

public static class DatabaseExtensions
{
    public static IServiceCollection AddDatabase(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<FitPlanDbContext>(options =>
            options.UseSqlServer(
                configuration.GetConnectionString("FitPlanDb")));

        return services;
    }
}
