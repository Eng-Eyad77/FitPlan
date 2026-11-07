using Microsoft.Data.SqlClient;

namespace FitPlan.Migrator;

// The only databases the migrator may connect to: the Dev database, and throwaway test databases on this machine.
// Production isn't on the list, so it is refused even if someone passes its connection string.
public static class MigrationTarget
{
    public const string DevServer = "fitplan-sql-eyad-dev.database.windows.net";
    public const string DevDatabase = "FitPlanDb-dev";

    private const string TestDatabasePrefix = "FitPlanTests_";

    private static readonly string[] LocalHosts = ["localhost", "127.0.0.1", "(local)", "."];

    // Signs in with the account from `az login`. No password or key is stored.
    public static string Dev => new SqlConnectionStringBuilder
    {
        DataSource = $"tcp:{DevServer},1433",
        InitialCatalog = DevDatabase,
        Authentication = SqlAuthenticationMethod.ActiveDirectoryDefault,
        Encrypt = SqlConnectionEncryptOption.Mandatory,
        ConnectTimeout = 120
    }.ConnectionString;

    public static bool IsAllowed(string connectionString, out string reason)
    {
        SqlConnectionStringBuilder builder;
        try
        {
            builder = new SqlConnectionStringBuilder(connectionString);
        }
        catch (ArgumentException)
        {
            reason = "The connection string can't be read.";
            return false;
        }

        var host = builder.DataSource
            .Replace("tcp:", "", StringComparison.OrdinalIgnoreCase)
            .Split(',')[0]
            .Split('\\')[0]
            .Trim();
        var database = builder.InitialCatalog;

        if (host.Equals(DevServer, StringComparison.OrdinalIgnoreCase) && database == DevDatabase)
        {
            reason = "";
            return true;
        }

        if (LocalHosts.Contains(host, StringComparer.OrdinalIgnoreCase) && database.StartsWith(TestDatabasePrefix, StringComparison.Ordinal))
        {
            reason = "";
            return true;
        }

        reason = $"{host}/{database} isn't the Dev database or a local test database.";
        return false;
    }
}
