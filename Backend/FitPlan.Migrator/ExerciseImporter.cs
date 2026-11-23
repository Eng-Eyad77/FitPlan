using System.Data;
using Microsoft.Data.SqlClient;

namespace FitPlan.Migrator;

public sealed record ImportReport(
    RunOutcome Outcome,
    string Message,
    int? RowsBefore = null,
    int? Inserted = null,
    int? RowsAfter = null,
    int? Updated = null);

// Writes approved files into the database. Every command here runs as `fitplan-migrator`, in one
// transaction, and none deletes a row:
// - ImportAsync adds the exercises the database doesn't have yet, and never changes an existing one.
// - UpdateDetailsAsync (Phase 11C) fills an existing exercise's equipment and muscles, and nothing else.
// - ImportTranslationsAsync (Phase 11C) adds or replaces one language's text for exercises and terms.
// Running any of them again with the same file changes nothing.
public static class ExerciseImporter
{
    private const string LockName = "FitPlan.Migrator";

    private const string InsertMissing = """
        INSERT INTO [dbo].[Exercises] ([Id], [Name], [GifUrl], [BodyPart], [Instructions], [Equipments], [TargetMuscles], [SecondaryMuscles])
        SELECT j.[Id], j.[Name], j.[GifUrl], j.[BodyPart], j.[Instructions],
            ISNULL(j.[Equipments], N'[]'), ISNULL(j.[TargetMuscles], N'[]'), ISNULL(j.[SecondaryMuscles], N'[]')
        FROM OPENJSON(@rows) WITH (
            [Id] nvarchar(450) '$.id',
            [Name] nvarchar(100) '$.name',
            [GifUrl] nvarchar(max) '$.gifUrl',
            [BodyPart] nvarchar(max) '$.bodyPart',
            [Instructions] nvarchar(max) '$.instructions' AS JSON,
            [Equipments] nvarchar(max) '$.equipments' AS JSON,
            [TargetMuscles] nvarchar(max) '$.targetMuscles' AS JSON,
            [SecondaryMuscles] nvarchar(max) '$.secondaryMuscles' AS JSON) AS j
        WHERE NOT EXISTS (SELECT 1 FROM [dbo].[Exercises] AS e WHERE e.[Id] = j.[Id]);
        SELECT @@ROWCOUNT;
        """;

    // Only the three detail columns, and only where they differ, so a second run updates nothing.
    private const string UpdateDetails = """
        UPDATE e
        SET e.[Equipments] = j.[Equipments], e.[TargetMuscles] = j.[TargetMuscles], e.[SecondaryMuscles] = j.[SecondaryMuscles]
        FROM [dbo].[Exercises] AS e
        INNER JOIN OPENJSON(@rows) WITH (
            [Id] nvarchar(450) '$.id',
            [Equipments] nvarchar(max) '$.equipments' AS JSON,
            [TargetMuscles] nvarchar(max) '$.targetMuscles' AS JSON,
            [SecondaryMuscles] nvarchar(max) '$.secondaryMuscles' AS JSON) AS j ON e.[Id] = j.[Id]
        WHERE e.[Equipments] COLLATE Latin1_General_BIN2 <> j.[Equipments]
            OR e.[TargetMuscles] COLLATE Latin1_General_BIN2 <> j.[TargetMuscles]
            OR e.[SecondaryMuscles] COLLATE Latin1_General_BIN2 <> j.[SecondaryMuscles];
        SELECT @@ROWCOUNT;
        """;

    private const string MatchedIds = """
        SELECT COUNT(*) FROM OPENJSON(@rows) WITH ([Id] nvarchar(450) '$.id') AS j
        WHERE EXISTS (SELECT 1 FROM [dbo].[Exercises] AS e WHERE e.[Id] = j.[Id]);
        """;

    // A changed text is marked as not reviewed again. Exercises the database doesn't have are skipped.
    private const string UpdateTranslations = """
        UPDATE t
        SET t.[Name] = j.[Name], t.[Instructions] = j.[Instructions], t.[Reviewed] = CAST(0 AS bit)
        FROM [dbo].[ExerciseTranslations] AS t
        INNER JOIN OPENJSON(@rows) WITH (
            [Id] nvarchar(450) '$.id',
            [Name] nvarchar(150) '$.name',
            [Instructions] nvarchar(max) '$.instructions' AS JSON) AS j ON t.[ExerciseId] = j.[Id]
        WHERE t.[Language] = @language
            AND (t.[Name] COLLATE Latin1_General_BIN2 <> j.[Name] OR t.[Instructions] COLLATE Latin1_General_BIN2 <> j.[Instructions]);
        SELECT @@ROWCOUNT;
        """;

    private const string InsertTranslations = """
        INSERT INTO [dbo].[ExerciseTranslations] ([ExerciseId], [Language], [Name], [Instructions], [Reviewed])
        SELECT e.[Id], @language, j.[Name], j.[Instructions], CAST(0 AS bit)
        FROM OPENJSON(@rows) WITH (
            [Id] nvarchar(450) '$.id',
            [Name] nvarchar(150) '$.name',
            [Instructions] nvarchar(max) '$.instructions' AS JSON) AS j
        INNER JOIN [dbo].[Exercises] AS e ON e.[Id] = j.[Id]
        WHERE NOT EXISTS (SELECT 1 FROM [dbo].[ExerciseTranslations] AS t WHERE t.[ExerciseId] = e.[Id] AND t.[Language] = @language);
        SELECT @@ROWCOUNT;
        """;

    private const string UpdateTerms = """
        UPDATE t
        SET t.[Text] = j.[Text]
        FROM [dbo].[TermTranslations] AS t
        INNER JOIN OPENJSON(@terms) WITH (
            [Kind] nvarchar(20) '$.kind',
            [Term] nvarchar(100) '$.term',
            [Text] nvarchar(150) '$.text') AS j ON t.[Kind] = j.[Kind] AND t.[Term] = j.[Term]
        WHERE t.[Language] = @language AND t.[Text] COLLATE Latin1_General_BIN2 <> j.[Text];
        SELECT @@ROWCOUNT;
        """;

    private const string InsertTerms = """
        INSERT INTO [dbo].[TermTranslations] ([Kind], [Term], [Language], [Text])
        SELECT j.[Kind], j.[Term], @language, j.[Text]
        FROM OPENJSON(@terms) WITH (
            [Kind] nvarchar(20) '$.kind',
            [Term] nvarchar(100) '$.term',
            [Text] nvarchar(150) '$.text') AS j
        WHERE NOT EXISTS (SELECT 1 FROM [dbo].[TermTranslations] AS t
            WHERE t.[Kind] = j.[Kind] AND t.[Term] = j.[Term] AND t.[Language] = @language);
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

        return await RunAsync(exercises.Sha256, approvedSha256, connectionString,
            (connection, transaction) => InsertAsync(connection, transaction, exercises, cancellationToken), cancellationToken);
    }

    public static async Task<ImportReport> UpdateDetailsAsync(
        byte[] file, string approvedSha256, string connectionString, CancellationToken cancellationToken = default)
    {
        ValidatedExercises exercises;
        try
        {
            exercises = ExerciseFile.Validate(file);
            var without = exercises.Rows.FirstOrDefault(r => r.Equipments is null || r.TargetMuscles is null || r.SecondaryMuscles is null);
            if (without is not null)
            {
                throw new ExerciseFileRejectedException(
                    $"Exercise {without.Id} has no equipment or muscle lists. Fetch the list again with this version of the migrator.");
            }
        }
        catch (ExerciseFileRejectedException ex)
        {
            return new ImportReport(RunOutcome.Refused, $"The file was rejected: {ex.Message}");
        }

        return await RunAsync(exercises.Sha256, approvedSha256, connectionString,
            (connection, transaction) => UpdateAsync(connection, transaction, exercises, cancellationToken), cancellationToken);
    }

    public static async Task<ImportReport> ImportTranslationsAsync(
        byte[] file, string approvedSha256, string connectionString, CancellationToken cancellationToken = default)
    {
        ValidatedTranslations pack;
        try
        {
            pack = TranslationFile.Validate(file);
        }
        catch (ExerciseFileRejectedException ex)
        {
            return new ImportReport(RunOutcome.Refused, $"The file was rejected: {ex.Message}");
        }

        return await RunAsync(pack.Sha256, approvedSha256, connectionString,
            (connection, transaction) => TranslateAsync(connection, transaction, pack, cancellationToken), cancellationToken);
    }

    // The checks, lock and user switch every command shares. `work` runs inside one transaction and
    // returns Succeeded to commit; anything else is rolled back.
    private static async Task<ImportReport> RunAsync(
        string fileSha256,
        string approvedSha256,
        string connectionString,
        Func<SqlConnection, SqlTransaction, Task<ImportReport>> work,
        CancellationToken cancellationToken)
    {
        if (!string.Equals(fileSha256, approvedSha256.Trim(), StringComparison.OrdinalIgnoreCase))
        {
            return new ImportReport(RunOutcome.Refused, $"The file's SHA-256 is {fileSha256}, which isn't the approved hash.");
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

        try
        {
            await using var transaction = (SqlTransaction)await connection.BeginTransactionAsync(cancellationToken);
            try
            {
                var report = await work(connection, transaction);
                if (report.Outcome == RunOutcome.Succeeded)
                {
                    await transaction.CommitAsync(cancellationToken);
                }
                else
                {
                    await transaction.RollbackAsync(cancellationToken);
                }

                return report;
            }
            catch (SqlException ex)
            {
                // XACT_ABORT rolls the whole transaction back
                return new ImportReport(RunOutcome.Failed, $"SQL error {ex.Number}: {ex.Message} Nothing was changed.");
            }
        }
        finally
        {
            if (await RevertAsync(connection, cookie) != originalUser)
            {
                await connection.CloseAsync();
            }
        }
    }

    private static async Task<ImportReport> InsertAsync(
        SqlConnection connection, SqlTransaction transaction, ValidatedExercises exercises, CancellationToken cancellationToken)
    {
        var before = await CountAsync(connection, transaction, "Exercises", cancellationToken);
        var inserted = await RowsAsync(connection, transaction, InsertMissing, cancellationToken,
            ("@rows", ExerciseFile.ToImportJson(exercises.Rows)));
        var after = await CountAsync(connection, transaction, "Exercises", cancellationToken);

        if (after != before + inserted)
        {
            return new ImportReport(RunOutcome.Failed,
                $"The row count went from {before} to {after} after adding {inserted}. Rolled back: nothing changed.", before, 0, before);
        }

        return new ImportReport(RunOutcome.Succeeded,
            $"Added {inserted} exercises. {exercises.Rows.Count - inserted} were already there and weren't touched.",
            before, inserted, after);
    }

    private static async Task<ImportReport> UpdateAsync(
        SqlConnection connection, SqlTransaction transaction, ValidatedExercises exercises, CancellationToken cancellationToken)
    {
        var rows = ExerciseFile.ToImportJson(exercises.Rows);
        var before = await CountAsync(connection, transaction, "Exercises", cancellationToken);
        var matched = await RowsAsync(connection, transaction, MatchedIds, cancellationToken, ("@rows", rows));
        var updated = await RowsAsync(connection, transaction, UpdateDetails, cancellationToken, ("@rows", rows));
        var after = await CountAsync(connection, transaction, "Exercises", cancellationToken);

        if (after != before || updated > matched)
        {
            return new ImportReport(RunOutcome.Failed,
                $"Expected {before} rows and at most {matched} updates, found {after} rows and {updated} updates. Rolled back: nothing changed.");
        }

        return new ImportReport(RunOutcome.Succeeded,
            $"Updated the equipment and muscles of {updated} exercises. {matched - updated} already had them, " +
            $"and {exercises.Rows.Count - matched} in the file aren't in the database (left alone).",
            before, 0, after, updated);
    }

    private static async Task<ImportReport> TranslateAsync(
        SqlConnection connection, SqlTransaction transaction, ValidatedTranslations pack, CancellationToken cancellationToken)
    {
        var rows = TranslationFile.ToImportJson(pack);
        var terms = TranslationFile.TermsToImportJson(pack);
        var language = ("@language", pack.Language);

        var matched = await RowsAsync(connection, transaction, MatchedIds, cancellationToken, ("@rows", rows));
        var updated = await RowsAsync(connection, transaction, UpdateTranslations, cancellationToken, ("@rows", rows), language);
        var inserted = await RowsAsync(connection, transaction, InsertTranslations, cancellationToken, ("@rows", rows), language);
        var termsUpdated = await RowsAsync(connection, transaction, UpdateTerms, cancellationToken, ("@terms", terms), language);
        var termsInserted = await RowsAsync(connection, transaction, InsertTerms, cancellationToken, ("@terms", terms), language);

        var missing = await RowsAsync(connection, transaction, """
            SELECT COUNT(*) FROM [dbo].[Exercises] AS e
            WHERE NOT EXISTS (SELECT 1 FROM [dbo].[ExerciseTranslations] AS t WHERE t.[ExerciseId] = e.[Id] AND t.[Language] = @language);
            """, cancellationToken, language);

        if (inserted + updated > matched)
        {
            return new ImportReport(RunOutcome.Failed,
                $"Wrote {inserted + updated} texts for {matched} known exercises. Rolled back: nothing changed.");
        }

        return new ImportReport(RunOutcome.Succeeded,
            $"{pack.Language}: added {inserted} and replaced {updated} exercise texts ({matched - inserted - updated} unchanged, " +
            $"{pack.Exercises.Count - matched} in the file aren't in the database). Terms: added {termsInserted}, replaced {termsUpdated}. " +
            $"Exercises still without {pack.Language} text: {missing}.",
            null, inserted, null, updated);
    }

    private static async Task<int> CountAsync(SqlConnection connection, SqlTransaction transaction, string table, CancellationToken cancellationToken) =>
        await RowsAsync(connection, transaction, $"SELECT COUNT(*) FROM [dbo].[{table}];", cancellationToken);

    private static async Task<int> RowsAsync(
        SqlConnection connection, SqlTransaction transaction, string sql, CancellationToken cancellationToken,
        params (string Name, string Value)[] parameters)
    {
        using var command = new SqlCommand(sql, connection, transaction) { CommandTimeout = 600 };
        foreach (var (name, value) in parameters)
        {
            command.Parameters.Add(name, SqlDbType.NVarChar, -1).Value = value;
        }

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
