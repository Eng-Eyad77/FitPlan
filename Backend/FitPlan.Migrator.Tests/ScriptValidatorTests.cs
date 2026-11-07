using FitPlan.Migrator.Tests.Infrastructure;
using Xunit;

namespace FitPlan.Migrator.Tests;

// No database: these only check what the validator accepts.
public sealed class ScriptValidatorTests
{
    // One migration step that tests replace, so the script keeps its shape and only the statement changes.
    private const string Step = "CREATE INDEX [IX_WorkoutSessions_WorkoutPlanId] ON [WorkoutSessions] ([WorkoutPlanId]);";

    private readonly ScriptValidator validator = new(Scripts.Known);

    [Fact]
    public void Accepts_the_script_EF_Core_generates_for_the_API()
    {
        var script = Scripts.Idempotent();

        var result = validator.Validate(Scripts.Bytes(script));

        Assert.Equal([Scripts.InitialCreate, Scripts.AddWorkoutSessions, Scripts.AddUserWeeklyGoal], result.MigrationIds);
        Assert.Equal(4, result.Batches.Count);
        Assert.Null(result.Batches[0].MigrationId);
        Assert.Equal(Scripts.Sha256(script), result.Sha256);
    }

    [Fact]
    public void Accepts_the_same_script_with_a_byte_order_mark()
    {
        var bytes = new byte[] { 0xEF, 0xBB, 0xBF }.Concat(Scripts.Bytes(Scripts.Idempotent())).ToArray();

        Assert.Equal(3, validator.Validate(bytes).MigrationIds.Count);
    }

    [Theory]
    [InlineData("REVERT;", "RevertStatement")]
    [InlineData("EXECUTE AS USER = 'dbo';", "ExecuteAsStatement")]
    [InlineData("ALTER ROLE db_owner ADD MEMBER [fitplan-migrator];", "AlterRoleStatement")]
    [InlineData("GRANT CONTROL TO [fitplan-migrator];", "GrantStatement")]
    [InlineData("DENY SELECT ON [Users] TO [public];", "DenyStatement")]
    [InlineData("CREATE USER [intruder] WITHOUT LOGIN;", "CreateUserStatement")]
    [InlineData("ALTER AUTHORIZATION ON SCHEMA::dbo TO [fitplan-migrator];", "AlterAuthorizationStatement")]
    [InlineData("RAISERROR (N'boom', 16, 1);", "RaiseErrorStatement")]
    [InlineData("THROW 50000, N'boom', 1;", "ThrowStatement")]
    [InlineData("USE master;", "UseStatement")]
    [InlineData("ALTER DATABASE CURRENT SET SINGLE_USER;", "AlterDatabase")]
    [InlineData("PRINT N'hello';", "PrintStatement")]
    public void Rejects_statements_that_change_identity_permissions_or_error_handling(string statement, string expected)
    {
        var script = Scripts.ReplaceOnce(Scripts.Idempotent(), Step, statement);

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));

        Assert.Contains(expected, ex.Message);
        Assert.Contains("forbidden", ex.Message);
    }

    [Theory]
    [InlineData("EXEC(N'REVERT');", "RevertStatement")]
    [InlineData("EXEC(N'ALTER ROLE db_owner ADD MEMBER [fitplan-migrator]');", "AlterRoleStatement")]
    [InlineData("EXEC(N'EXEC(N''GRANT CONTROL TO [fitplan-migrator]'')');", "ExecuteStatement isn't allowed")]
    public void Rejects_forbidden_statements_hidden_inside_EXEC(string statement, string expected)
    {
        var script = Scripts.ReplaceOnce(Scripts.Idempotent(), Step, statement);

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));

        Assert.Contains(expected, ex.Message);
    }

    [Theory]
    [InlineData("EXEC sp_executesql N'DROP TABLE [Users]';", "Only EXEC(N'...')")]
    [InlineData("EXEC(N'DROP TABLE [Users]' + N'');", "Only EXEC(N'...')")]
    [InlineData("EXEC sp_rename N'[Users]', N'People';", "Only EXEC(N'...')")]
    [InlineData("EXEC(N'SELECT 1');", "SelectStatement isn't allowed")]
    [InlineData("EXEC(N'CREATE INDEX [A] ON [Users] ([Id]); CREATE INDEX [B] ON [Users] ([Id]);');", "exactly one statement")]
    [InlineData("SELECT * FROM [Users];", "SelectStatement isn't allowed")]
    [InlineData("DELETE FROM [Users];", "DeleteStatement isn't allowed")]
    [InlineData("DROP TABLE [__EFMigrationsHistory];", "Only the final step")]
    [InlineData("CREATE INDEX [IX_History] ON [__EFMigrationsHistory] ([ProductVersion]);", "Only the final step")]
    public void Rejects_statements_outside_the_allowed_list(string statement, string expected)
    {
        var script = Scripts.ReplaceOnce(Scripts.Idempotent(), Step, statement);

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));

        Assert.Contains(expected, ex.Message);
    }

    [Fact]
    public void Rejects_a_step_with_more_than_one_statement()
    {
        var script = Scripts.ReplaceOnce(Scripts.Idempotent(), Step, Step + " " + Step.Replace("IX_WorkoutSessions_WorkoutPlanId", "IX_Copy"));

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));

        Assert.Contains("exactly one statement", ex.Message);
    }

    [Fact]
    public void Rejects_a_statement_outside_a_migration_check()
    {
        var script = Scripts.ReplaceOnce(Scripts.Idempotent(),
            "BEGIN TRANSACTION;" + Environment.NewLine + "IF NOT EXISTS (" + Environment.NewLine + "    SELECT * FROM [__EFMigrationsHistory]" + Environment.NewLine + $"    WHERE [MigrationId] = N'{Scripts.AddUserWeeklyGoal}'",
            "BEGIN TRANSACTION;" + Environment.NewLine + "CREATE TABLE [Sneaky] ([Id] int NOT NULL);" + Environment.NewLine + "IF NOT EXISTS (" + Environment.NewLine + "    SELECT * FROM [__EFMigrationsHistory]" + Environment.NewLine + $"    WHERE [MigrationId] = N'{Scripts.AddUserWeeklyGoal}'");

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));

        Assert.Contains("outside an EF Core migration check", ex.Message);
    }

    [Fact]
    public void Rejects_an_extra_batch()
    {
        var script = Scripts.Idempotent() + "SELECT 1;" + Environment.NewLine + "GO" + Environment.NewLine;

        Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));
    }

    [Fact]
    public void Rejects_a_migration_batch_without_COMMIT()
    {
        var script = Scripts.Idempotent();
        var last = script.LastIndexOf("COMMIT;", StringComparison.Ordinal);
        script = script.Remove(last, "COMMIT;".Length);

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));

        Assert.Contains("COMMIT", ex.Message);
    }

    [Fact]
    public void Rejects_a_changed_history_table_batch()
    {
        var script = Scripts.ReplaceOnce(Scripts.Idempotent(), "[ProductVersion] nvarchar(32) NOT NULL", "[ProductVersion] nvarchar(32) NULL");

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));

        Assert.Contains("history table batch", ex.Message);
    }

    [Fact]
    public void Rejects_a_migration_the_API_doesnt_have()
    {
        var script = Scripts.Idempotent().Replace(Scripts.AddUserWeeklyGoal, "20991231000000_NotInTheApi", StringComparison.Ordinal);

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));

        Assert.Contains("20991231000000_NotInTheApi", ex.Message);
    }

    [Fact]
    public void Rejects_a_script_recorded_with_another_EF_Core_version()
    {
        var script = Scripts.Idempotent().Replace($"N'{Scripts.Known.ProductVersion}'", "N'9.0.0'", StringComparison.Ordinal);

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));

        Assert.Contains("doesn't end by recording", ex.Message);
    }

    [Fact]
    public void Rejects_SQL_that_doesnt_parse()
    {
        var script = Scripts.ReplaceOnce(Scripts.Idempotent(), Step, "CREATE INDEX ON ON ON;");

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(Scripts.Bytes(script)));

        Assert.Contains("doesn't parse", ex.Message);
    }

    [Fact]
    public void Rejects_a_file_that_isnt_UTF8()
    {
        var bytes = Scripts.Bytes(Scripts.Idempotent()).Append((byte)0xFF).ToArray();

        var ex = Assert.Throws<ScriptRejectedException>(() => validator.Validate(bytes));

        Assert.Contains("UTF-8", ex.Message);
    }
}
