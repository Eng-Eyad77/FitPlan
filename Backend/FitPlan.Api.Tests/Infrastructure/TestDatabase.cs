using Microsoft.Data.SqlClient;

namespace FitPlan.Api.Tests.Infrastructure;

// Builds connection strings for throwaway test databases, and refuses anything that is not on this machine.
// CI points FITPLAN_TEST_SQL at the SQL Server container. Locally it falls back to SQL Express.
public static class TestDatabase
{
    private const string ServerVariable = "FITPLAN_TEST_SQL";
    private const string LocalDefault = "Server=localhost\\SQLEXPRESS;Trusted_Connection=True;TrustServerCertificate=True;";
    private const string NamePrefix = "FitPlanTests_";

    private static readonly string[] AllowedHosts = ["localhost", "127.0.0.1", "(local)", "."];

    public static string CreateUniqueConnectionString()
    {
        var value = Environment.GetEnvironmentVariable(ServerVariable);
        return BuildConnectionString(string.IsNullOrWhiteSpace(value) ? LocalDefault : value, NamePrefix + Guid.NewGuid().ToString("N"));
    }

    public static string BuildConnectionString(string serverConnectionString, string databaseName)
    {
        var builder = new SqlConnectionStringBuilder(serverConnectionString);

        var host = builder.DataSource.Replace("tcp:", "", StringComparison.OrdinalIgnoreCase).Split(',')[0].Split('\\')[0].Trim();
        if (!AllowedHosts.Contains(host, StringComparer.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Tests only run against a SQL Server on this machine.");
        }

        if (!databaseName.StartsWith(NamePrefix, StringComparison.Ordinal))
        {
            throw new InvalidOperationException($"Test database names must start with {NamePrefix}.");
        }

        builder.InitialCatalog = databaseName;
        return builder.ConnectionString;
    }
}
