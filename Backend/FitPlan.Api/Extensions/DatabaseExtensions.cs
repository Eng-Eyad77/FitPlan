
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
        var connectionString = WithWakeUpTime(configuration.GetConnectionString("FitPlanDb"));
        EnsureDevUsesDevDatabase(environment, connectionString);

        services.AddDbContext<FitPlanDbContext>(options =>
            options.UseSqlServer(connectionString, sql => sql.EnableRetryOnFailure(
                maxRetryCount: MaxRetryCount,
                maxRetryDelay: MaxRetryDelay,
                errorNumbersToAdd: null)));

        return services;
    }

    // A paused serverless database wakes up in two ways, and both need handling:
    // - the login waits while the database resumes. SqlClient's default 15 s gives up first, with
    //   "Connection Timeout Expired" (-2), which EF doesn't retry. So the connection waits up to 60 s.
    // - the database answers 40613 "not currently available". EF retries that, waiting longer
    //   each time, about 20 s in total.
    // A user-started transaction can't be retried this way, so the code must not open one
    // without going through Database.CreateExecutionStrategy().
    public const int MinConnectTimeoutSeconds = 60;
    private const int MaxRetryCount = 4;
    private static readonly TimeSpan MaxRetryDelay = TimeSpan.FromSeconds(10);

    // Raises the connect timeout to MinConnectTimeoutSeconds, and keeps a longer one if set.
    public static string? WithWakeUpTime(string? connectionString)
    {
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return connectionString;
        }

        var builder = new SqlConnectionStringBuilder(connectionString);
        if (builder.ConnectTimeout < MinConnectTimeoutSeconds)
        {
            builder.ConnectTimeout = MinConnectTimeoutSeconds;
        }

        return builder.ConnectionString;
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
