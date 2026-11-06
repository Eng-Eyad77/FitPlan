
using FitPlan.Api.Data;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Extensions;

public static class DatabaseExtensions
{
    private const string DevEnvironment = "Dev";
    private const string DevServerHost = "fitplan-sql-eyad-dev.database.windows.net";
    private const string DevDatabase = "FitPlanDb-dev";

    public static IServiceCollection AddDatabase(
        this IServiceCollection services,
        IConfiguration configuration,
        IHostEnvironment environment)
    {
        var connectionString = configuration.GetConnectionString("FitPlanDb");
        EnsureDevUsesDevDatabase(environment, connectionString);

        services.AddDbContext<FitPlanDbContext>(options =>
            options.UseSqlServer(connectionString));

        return services;
    }

    // The Dev API must never reach Production, so it only starts against the Dev database.
    private static void EnsureDevUsesDevDatabase(IHostEnvironment environment, string? connectionString)
    {
        if (!environment.IsEnvironment(DevEnvironment))
        {
            return;
        }

        var builder = new SqlConnectionStringBuilder(connectionString);
        var host = builder.DataSource.Replace("tcp:", "", StringComparison.OrdinalIgnoreCase).Split(',')[0].Trim();

        if (!host.Equals(DevServerHost, StringComparison.OrdinalIgnoreCase)
            || !builder.InitialCatalog.Equals(DevDatabase, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException(
                "The Dev environment can only connect to the Dev database. Check the FitPlanDb connection string.");
        }
    }
}
