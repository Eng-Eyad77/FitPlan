using System.Data;
using Microsoft.Data.SqlClient;

namespace FitPlan.Migrator;

public sealed record ImportReport(
    RunOutcome Outcome,
    string Message,
    int? RowsBefore = null,
    int? Inserted = null,
    int? RowsAfter = null);

// Adds the exercises from an approved file that the database doesn't have yet. It never changes or
// deletes a row, so running it again adds nothing. Runs as `fitplan-migrator`, in one transaction.
public static class ExerciseImporter
{
    private const string LockName = "FitPlan.Migrator";

    private const string InsertMissing = """
        INSERT INTO [dbo].[Exercises] ([Id], [Name], [GifUrl], [BodyPart], [Instructions])
        SELECT j.[Id], j.[Name], j.[GifUrl], j.[BodyPart], j.[Instructions]
        FROM OPENJSON(@rows) WITH (
            [Id] nvarchar(450) '$.id',
            [Name] nvarchar(100) '$.name',
            [GifUrl] nvarchar(max) '$.gifUrl',
            [BodyPart] nvarchar(max) '$.bodyPart',
            [Instructions] nvarchar(max) '$.instructions' AS JSON) AS j
        WHERE NOT EXISTS (SELECT 1 FROM [dbo].[Exercises] AS e WHERE e.[Id] = j.[Id]);
        SELECT @@ROWCOUNT;
        """;

    public static async Task<ImportReport> ImportAsync(
        byte[] file, string approvedSha256, string connectionString, CancellationToken cancellationToken = default)
    {
        ValidatedExercises exercises;
        try
        {
            exercises = ExerciseFile.Validate(file);
        }
        catch (ExerciseFileRejectedException ex)
        {
            return new ImportReport(RunOutcome.Refused, $"The file was rejected: {ex.Message}");
        }

        if (!string.Equals(exercises.Sha256, approvedSha256.Trim(), StringComparison.OrdinalIgnoreCase))
        {
            return new ImportReport(RunOutcome.Refused, $"The file's SHA-256 is {exercises.Sha256}, which isn't the approved hash.");
        }

        if (!MigrationTarget.IsAllowed(connectionString, out var reason))
        {
            return new ImportReport(RunOutcome.Refused, reason);
        }

        // one unpooled session: closing it really ends the impersonation
        var builder = new SqlConnectionStringBuilder(connectionString) { Pooling = false, ApplicationName = "FitPlan.Migrator" };
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
            return new ImportReport(RunOutcome.LockBusy, "Another migrator run holds the lock. Nothing was run.");
        }

        var originalUser = await ScalarAsync<string>(connection, "SELECT USER_NAME();", cancellationToken);
        var cookie = await ScalarAsync<byte[]>(connection, $"""
            DECLARE @cookie varbinary(8000);
            EXECUTE AS USER = N'{ScriptRunner.MigratorUser}' WITH COOKIE INTO @cookie;
            SELECT @cookie;
            """, cancellationToken);

        ImportReport report;
        try
        {
            report = await InsertAsync(connection, exercises, cancellationToken);
        }
        finally
        {
            if (await RevertAsync(connection, cookie) != originalUser)
            {
                await connection.CloseAsync();
            }
        }

        return report;
    }

    private static async Task<ImportReport> InsertAsync(SqlConnection connection, ValidatedExercises exercises, CancellationToken cancellationToken)
    {
        await using var transaction = (SqlTransaction)await connection.BeginTransactionAsync(cancellationToken);
        try
        {
            var before = await CountAsync(connection, transaction, cancellationToken);

            using var insert = new SqlCommand(InsertMissing, connection, transaction) { CommandTimeout = 600 };
            insert.Parameters.Add("@rows", SqlDbType.NVarChar, -1).Value = ExerciseFile.ToImportJson(exercises.Rows);
            var inserted = (int)(await insert.ExecuteScalarAsync(cancellationToken))!;

            var after = await CountAsync(connection, transaction, cancellationToken);
            if (after != before + inserted)
            {
                await transaction.RollbackAsync(cancellationToken);
                return new ImportReport(RunOutcome.Failed,
                    $"The row count went from {before} to {after} after adding {inserted}. Rolled back: nothing changed.", before, 0, before);
            }

            await transaction.CommitAsync(cancellationToken);
            return new ImportReport(RunOutcome.Succeeded,
                $"Added {inserted} exercises. {exercises.Rows.Count - inserted} were already there and weren't touched.",
                before, inserted, after);
        }
        catch (SqlException ex)
        {
            // XACT_ABORT rolls the whole transaction back
            return new ImportReport(RunOutcome.Failed, $"SQL error {ex.Number}: {ex.Message} Nothing was added.");
        }
    }

    private static async Task<int> CountAsync(SqlConnection connection, SqlTransaction transaction, CancellationToken cancellationToken)
    {
        using var command = new SqlCommand("SELECT COUNT(*) FROM [dbo].[Exercises];", connection, transaction);
        return (int)(await command.ExecuteScalarAsync(cancellationToken))!;
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

    private static async Task ExecuteAsync(SqlConnection connection, string sql, CancellationToken cancellationToken)
    {
        using var command = new SqlCommand(sql, connection);
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static async Task<T> ScalarAsync<T>(SqlConnection connection, string sql, CancellationToken cancellationToken)
    {
        using var command = new SqlCommand(sql, connection) { CommandTimeout = 120 };
        return (T)(await command.ExecuteScalarAsync(cancellationToken))!;
    }
}
