using System.Data;
using Microsoft.Data.SqlClient;

namespace FitPlan.Migrator;

public enum RunOutcome
{
    Succeeded,
    Refused,
    LockBusy,
    Failed
}

public sealed record RunReport(
    RunOutcome Outcome,
    string Message,
    IReadOnlyList<string> AppliedBefore,
    IReadOnlyList<string> AppliedAfter,
    int? FailedBatch = null,
    string? FailedMigrationId = null,
    int? SqlErrorNumber = null,
    string? UserAfterRevert = null);

// Runs a validated script as the database user `fitplan-migrator`, which has only db_ddladmin,
// db_datareader and db_datawriter. It stops at the first error and never retries.
public sealed class ScriptRunner
{
    public const string MigratorUser = "fitplan-migrator";
    private const string LockName = "FitPlan.Migrator";

    public static RunReport Refuse(string message) => new(RunOutcome.Refused, message, [], []);

    // Checks the approved hash, the script and the target before any connection is opened.
    public static async Task<RunReport> ApplyAsync(
        byte[] file, string approvedSha256, string connectionString, KnownMigrations known, CancellationToken cancellationToken = default)
    {
        ValidatedScript script;
        try
        {
            script = new ScriptValidator(known).Validate(file);
        }
        catch (ScriptRejectedException ex)
        {
            return Refuse($"The script was rejected: {ex.Message}");
        }

        if (!string.Equals(script.Sha256, approvedSha256.Trim(), StringComparison.OrdinalIgnoreCase))
        {
            return Refuse($"The script's SHA-256 is {script.Sha256}, which isn't the approved hash.");
        }

        if (!MigrationTarget.IsAllowed(connectionString, out var reason))
        {
            return Refuse(reason);
        }

        return await RunAsync(script, connectionString, cancellationToken);
    }

    internal static async Task<RunReport> RunAsync(ValidatedScript script, string connectionString, CancellationToken cancellationToken)
    {
        if (!MigrationTarget.IsAllowed(connectionString, out var reason))
        {
            return Refuse(reason);
        }

        // One unpooled session: if REVERT fails, closing the connection really ends the impersonation.
        var builder = new SqlConnectionStringBuilder(connectionString)
        {
            Pooling = false,
            ApplicationName = "FitPlan.Migrator"
        };

        await using var connection = new SqlConnection(builder.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await ExecuteAsync(connection, "SET XACT_ABORT ON;", cancellationToken);

        var lockResult = await ScalarAsync<int>(connection, $"""
            DECLARE @result int;
            EXEC @result = sp_getapplock @Resource = N'{LockName}', @LockMode = 'Exclusive', @LockOwner = 'Session', @LockTimeout = 0;
            SELECT @result;
            """, cancellationToken);
        if (lockResult < 0)
        {
            return new RunReport(RunOutcome.LockBusy, "Another migrator run holds the lock. Nothing was run.", [], []);
        }

        var originalUser = await ScalarAsync<string>(connection, "SELECT USER_NAME();", cancellationToken);
        var before = await ReadHistoryAsync(connection, cancellationToken);

        var cookie = await ScalarAsync<byte[]>(connection, $"""
            DECLARE @cookie varbinary(8000);
            EXECUTE AS USER = N'{MigratorUser}' WITH COOKIE INTO @cookie;
            SELECT @cookie;
            """, cancellationToken);

        RunReport? failure = null;
        string? userAfterRevert = null;
        try
        {
            foreach (var batch in script.Batches)
            {
                failure = await RunBatchAsync(connection, batch, before, cancellationToken);
                if (failure is not null)
                {
                    break;
                }
            }
        }
        finally
        {
            userAfterRevert = await RevertAsync(connection, cookie);
        }

        if (userAfterRevert != originalUser)
        {
            return (failure ?? new RunReport(RunOutcome.Failed, "", before, []))
                with
                {
                    Outcome = RunOutcome.Failed,
                    Message = $"{failure?.Message} REVERT didn't restore {originalUser}. The session was closed. Don't run again until the database is checked.".Trim(),
                    UserAfterRevert = userAfterRevert
                };
        }

        var after = await ReadHistoryAsync(connection, cancellationToken);
        await ExecuteAsync(connection, $"EXEC sp_releaseapplock @Resource = N'{LockName}', @LockOwner = 'Session';", cancellationToken);

        if (failure is not null)
        {
            return failure with { AppliedAfter = after, UserAfterRevert = userAfterRevert };
        }

        var missing = script.MigrationIds.Where(id => !after.Contains(id)).ToList();
        if (missing.Count > 0)
        {
            return new RunReport(RunOutcome.Failed,
                $"The script ran, but the history doesn't list {string.Join(", ", missing)}. Compare the schema before doing anything else.",
                before, after, UserAfterRevert: userAfterRevert);
        }

        return new RunReport(RunOutcome.Succeeded, "All batches ran.", before, after, UserAfterRevert: userAfterRevert);
    }

    private static async Task<RunReport?> RunBatchAsync(
        SqlConnection connection, ScriptBatch batch, IReadOnlyList<string> before, CancellationToken cancellationToken)
    {
        try
        {
            await ExecuteAsync(connection, batch.Sql, cancellationToken);
        }
        catch (SqlException ex)
        {
            return new RunReport(RunOutcome.Failed,
                $"Batch {batch.Number} ({batch.MigrationId ?? "history table"}) failed with SQL error {ex.Number}: {ex.Message} " +
                "Later batches didn't run. Don't run the script again before comparing the schema with a reference database.",
                before, [], batch.Number, batch.MigrationId, ex.Number);
        }

        // A batch must leave no transaction open and must not change who the session runs as.
        using var check = new SqlCommand("SELECT USER_NAME(), @@TRANCOUNT;", connection);
        await using var reader = await check.ExecuteReaderAsync(cancellationToken);
        await reader.ReadAsync(cancellationToken);
        var user = reader.GetString(0);
        var openTransactions = reader.GetInt32(1);

        if (user != MigratorUser || openTransactions != 0)
        {
            return new RunReport(RunOutcome.Failed,
                $"After batch {batch.Number}, the session ran as {user} with {openTransactions} open transaction(s). Later batches didn't run.",
                before, [], batch.Number, batch.MigrationId);
        }

        return null;
    }

    private static async Task<string?> RevertAsync(SqlConnection connection, byte[] cookie)
    {
        if (connection.State != ConnectionState.Open)
        {
            return null;
        }

        try
        {
            using var revert = new SqlCommand("REVERT WITH COOKIE = @cookie; SELECT USER_NAME();", connection);
            revert.Parameters.Add("@cookie", SqlDbType.VarBinary, 8000).Value = cookie;
            return (string?)await revert.ExecuteScalarAsync(CancellationToken.None);
        }
        catch (SqlException)
        {
            return null;
        }
    }

    private static async Task<IReadOnlyList<string>> ReadHistoryAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        using var command = new SqlCommand("""
            IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NOT NULL
                SELECT [MigrationId] FROM [__EFMigrationsHistory] ORDER BY [MigrationId];
            """, connection);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);

        var ids = new List<string>();
        while (await reader.ReadAsync(cancellationToken))
        {
            ids.Add(reader.GetString(0));
        }

        return ids;
    }

    private static async Task ExecuteAsync(SqlConnection connection, string sql, CancellationToken cancellationToken)
    {
        using var command = new SqlCommand(sql, connection) { CommandTimeout = 600 };
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static async Task<T> ScalarAsync<T>(SqlConnection connection, string sql, CancellationToken cancellationToken)
    {
        using var command = new SqlCommand(sql, connection) { CommandTimeout = 120 };
        return (T)(await command.ExecuteScalarAsync(cancellationToken))!;
    }
}
