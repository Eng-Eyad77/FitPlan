using Microsoft.Data.SqlClient;

namespace FitPlan.Migrator;

// The only databases the migrator may connect to: the Dev and Production databases, and throwaway
// test databases on this machine. Any other server or database is refused.
public static class MigrationTarget
{
    public const string DevServer = "fitplan-sql-eyad-dev.database.windows.net";
    public const string DevDatabase = "FitPlanDb-dev";
    public const string ProdServer = "fitplan-sql-eyad.database.windows.net";
    public const string ProdDatabase = "FitPlanDb";

    private const string TestDatabasePrefix = "FitPlanTests_";

    private static readonly string[] LocalHosts = ["localhost", "127.0.0.1", "(local)", "."];

    public static string Dev => Azure(DevServer, DevDatabase);

    public static string Prod => Azure(ProdServer, ProdDatabase);

    // Signs in with the account from `az login`. No password or key is stored.
    private static string Azure(string server, string database) => new SqlConnectionStringBuilder
    {
        DataSource = $"tcp:{server},1433",
        InitialCatalog = database,
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

        if ((host.Equals(DevServer, StringComparison.OrdinalIgnoreCase) && database == DevDatabase)
            || (host.Equals(ProdServer, StringComparison.OrdinalIgnoreCase) && database == ProdDatabase))
        {
            reason = "";
            return true;
        }

        if (LocalHosts.Contains(host, StringComparer.OrdinalIgnoreCase) && database.StartsWith(TestDatabasePrefix, StringComparison.Ordinal))
        {
            reason = "";
            return true;
        }

        reason = $"{host}/{database} isn't the Dev or Production database, or a local test database.";
        return false;
    }
}
