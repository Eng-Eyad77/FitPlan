using FitPlan.Migrator.Tests.Infrastructure;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Xunit;

namespace FitPlan.Migrator.Tests;

// Each test runs the migrator against its own throwaway database on the local test server.
public sealed class ScriptRunnerTests
{
    private static readonly string[] AllMigrations = [Scripts.InitialCreate, Scripts.AddWorkoutSessions, Scripts.AddUserWeeklyGoal];

    [Fact]
    public async Task Applies_every_migration_and_builds_the_same_schema_as_EF_Core()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        await using var reference = await MigratorDatabase.CreateAsync();
        await reference.Context.Database.MigrateAsync();
        var script = Scripts.Idempotent();

        var report = await ScriptRunner.ApplyAsync(Scripts.Bytes(script), Scripts.Sha256(script), database.ConnectionString, Scripts.Known);

        Assert.Equal(RunOutcome.Succeeded, report.Outcome);
        Assert.Empty(report.AppliedBefore);
        Assert.Equal(AllMigrations, report.AppliedAfter);
        Assert.Equal(AllMigrations, await database.HistoryAsync());
        Assert.Equal(await reference.SchemaAsync(), await database.SchemaAsync());
        Assert.Equal("dbo", report.UserAfterRevert);
    }

    [Fact]
    public async Task Running_the_same_script_again_changes_nothing()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        var script = Scripts.Idempotent();
        await ScriptRunner.ApplyAsync(Scripts.Bytes(script), Scripts.Sha256(script), database.ConnectionString, Scripts.Known);
        var schema = await database.SchemaAsync();

        var report = await ScriptRunner.ApplyAsync(Scripts.Bytes(script), Scripts.Sha256(script), database.ConnectionString, Scripts.Known);

        Assert.Equal(RunOutcome.Succeeded, report.Outcome);
        Assert.Equal(AllMigrations, report.AppliedBefore);
        Assert.Equal(AllMigrations, report.AppliedAfter);
        Assert.Equal(schema, await database.SchemaAsync());
    }

    [Fact]
    public async Task Continues_from_a_partly_migrated_database()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        await database.Context.GetService<IMigrator>().MigrateAsync(Scripts.InitialCreate);
        var script = Scripts.Idempotent();

        var report = await ScriptRunner.ApplyAsync(Scripts.Bytes(script), Scripts.Sha256(script), database.ConnectionString, Scripts.Known);

        Assert.Equal(RunOutcome.Succeeded, report.Outcome);
        Assert.Equal([Scripts.InitialCreate], report.AppliedBefore);
        Assert.Equal(AllMigrations, await database.HistoryAsync());
    }

    [Fact]
    public async Task Stops_at_the_first_failing_migration_and_keeps_the_ones_before_it()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        // A step of the second migration that fails at run time: [Users] already exists by then.
        var script = Scripts.ReplaceOnce(Scripts.Idempotent(),
            "CREATE INDEX [IX_WorkoutSessions_WorkoutPlanId] ON [WorkoutSessions] ([WorkoutPlanId]);",
            "CREATE TABLE [Users] ([Id] int NOT NULL);");

        var report = await ScriptRunner.ApplyAsync(Scripts.Bytes(script), Scripts.Sha256(script), database.ConnectionString, Scripts.Known);

        Assert.Equal(RunOutcome.Failed, report.Outcome);
        Assert.Equal(3, report.FailedBatch);
        Assert.Equal(Scripts.AddWorkoutSessions, report.FailedMigrationId);
        Assert.Equal(2714, report.SqlErrorNumber);
        Assert.Contains("Don't run the script again", report.Message);
        Assert.Equal([Scripts.InitialCreate], await database.HistoryAsync());
        Assert.Empty(await database.QueryAsync("SELECT name FROM sys.tables WHERE name = N'WorkoutSessions'"));
        Assert.Empty(await database.QueryAsync("SELECT name FROM sys.columns WHERE name = N'WeeklyGoal'"));
        Assert.Equal("dbo", report.UserAfterRevert);
    }

    [Fact]
    public async Task Stops_with_the_exact_error_when_the_migrator_lacks_schema_permissions()
    {
        await using var database = await MigratorDatabase.CreateAsync("db_datareader", "db_datawriter");
        var script = Scripts.Idempotent();

        var report = await ScriptRunner.ApplyAsync(Scripts.Bytes(script), Scripts.Sha256(script), database.ConnectionString, Scripts.Known);

        Assert.Equal(RunOutcome.Failed, report.Outcome);
        Assert.Equal(1, report.FailedBatch);
        Assert.Equal(262, report.SqlErrorNumber);
        Assert.Contains("CREATE TABLE permission denied", report.Message);
        Assert.Empty(await database.HistoryAsync());
        Assert.Equal("dbo", report.UserAfterRevert);
    }

    [Fact]
    public async Task Refuses_a_script_whose_hash_wasnt_approved_before_connecting()
    {
        var script = Scripts.Idempotent();
        // Connecting to this database would fail, so a refusal proves no connection was attempted.
        var missing = Api.Tests.Infrastructure.TestDatabase.CreateUniqueConnectionString();

        var report = await ScriptRunner.ApplyAsync(Scripts.Bytes(script), new string('0', 64), missing, Scripts.Known);

        Assert.Equal(RunOutcome.Refused, report.Outcome);
        Assert.Contains("isn't the approved hash", report.Message);
    }

    [Fact]
    public async Task Refuses_a_rejected_script_before_connecting()
    {
        var script = Scripts.Idempotent() + "SELECT 1;" + Environment.NewLine;
        var missing = Api.Tests.Infrastructure.TestDatabase.CreateUniqueConnectionString();

        var report = await ScriptRunner.ApplyAsync(Scripts.Bytes(script), Scripts.Sha256(script), missing, Scripts.Known);

        Assert.Equal(RunOutcome.Refused, report.Outcome);
        Assert.Contains("rejected", report.Message);
    }

    [Theory]
    [InlineData("Server=tcp:fitplan-sql-eyad.database.windows.net,1433;Initial Catalog=FitPlanDb;Authentication=Active Directory Default")]
    [InlineData("Server=tcp:fitplan-sql-eyad-dev.database.windows.net,1433;Initial Catalog=master;Authentication=Active Directory Default")]
    [InlineData("Server=tcp:fitplan-sql-eyad-dev.database.windows.net.attacker.example,1433;Initial Catalog=FitPlanDb-dev")]
    [InlineData("Server=localhost\\SQLEXPRESS;Initial Catalog=FitPlanDb;Trusted_Connection=True")]
    [InlineData("Server=db.example.com;Initial Catalog=FitPlanTests_abc")]
    public async Task Refuses_any_target_other_than_Dev_or_a_local_test_database(string connectionString)
    {
        var script = Scripts.Idempotent();

        var report = await ScriptRunner.ApplyAsync(Scripts.Bytes(script), Scripts.Sha256(script), connectionString, Scripts.Known);

        Assert.Equal(RunOutcome.Refused, report.Outcome);
        Assert.Contains("isn't the Dev database", report.Message);
    }

    [Fact]
    public void Allows_the_Dev_database()
    {
        Assert.True(MigrationTarget.IsAllowed(MigrationTarget.Dev, out _));
    }

    [Fact]
    public async Task Runs_nothing_while_another_run_holds_the_lock()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        await using var holder = new SqlConnection(database.ConnectionString);
        await holder.OpenAsync();
        await using (var take = new SqlCommand("EXEC sp_getapplock @Resource = N'FitPlan.Migrator', @LockMode = 'Exclusive', @LockOwner = 'Session';", holder))
        {
            await take.ExecuteNonQueryAsync();
        }

        var script = Scripts.Idempotent();
        var report = await ScriptRunner.ApplyAsync(Scripts.Bytes(script), Scripts.Sha256(script), database.ConnectionString, Scripts.Known);

        Assert.Equal(RunOutcome.LockBusy, report.Outcome);
        Assert.Empty(await database.HistoryAsync());
    }

    // The validator rejects these batches. They run here directly, to prove the runner's own checks
    // would still stop the run if something got past validation.
    [Fact]
    public async Task Stops_and_restores_the_original_user_when_a_batch_tries_to_revert()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        var script = new ValidatedScript("test", [new ScriptBatch(1, null, "REVERT;"), new ScriptBatch(2, null, "CREATE TABLE [NeverCreated] ([Id] int);")], []);

        var report = await ScriptRunner.RunAsync(script, database.ConnectionString, CancellationToken.None);

        Assert.Equal(RunOutcome.Failed, report.Outcome);
        Assert.Equal(1, report.FailedBatch);
        Assert.Equal("dbo", report.UserAfterRevert);
        Assert.Empty(await database.QueryAsync("SELECT name FROM sys.tables WHERE name = N'NeverCreated'"));
    }

    // DDL errors in the current migrations stop the whole batch either way, so this checks the setting itself.
    // Without XACT_ABORT, an error that ends only one statement lets the migration commit and record itself.
    [Fact]
    public async Task Runs_every_batch_with_XACT_ABORT_on()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        var script = new ValidatedScript("test", [new ScriptBatch(1, null, "IF (@@OPTIONS & 16384) = 0 THROW 50001, N'XACT_ABORT is off', 1;")], []);

        var report = await ScriptRunner.RunAsync(script, database.ConnectionString, CancellationToken.None);

        Assert.Equal(RunOutcome.Succeeded, report.Outcome);
    }

    [Fact]
    public async Task Stops_when_a_batch_leaves_a_transaction_open()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        var script = new ValidatedScript("test", [new ScriptBatch(1, null, "BEGIN TRANSACTION; CREATE TABLE [LeftOpen] ([Id] int);"), new ScriptBatch(2, null, "CREATE TABLE [NeverCreated] ([Id] int);")], []);

        var report = await ScriptRunner.RunAsync(script, database.ConnectionString, CancellationToken.None);

        Assert.Equal(RunOutcome.Failed, report.Outcome);
        Assert.Contains("1 open transaction", report.Message);
        Assert.Empty(await database.QueryAsync("SELECT name FROM sys.tables WHERE name IN (N'LeftOpen', N'NeverCreated')"));
    }

    [Fact]
    public async Task The_test_migrator_user_has_only_the_planned_roles()
    {
        await using var database = await MigratorDatabase.CreateAsync();

        var roles = await database.QueryAsync($"""
            SELECT r.name FROM sys.database_role_members m
            JOIN sys.database_principals r ON r.principal_id = m.role_principal_id
            JOIN sys.database_principals u ON u.principal_id = m.member_principal_id
            WHERE u.name = N'{ScriptRunner.MigratorUser}' ORDER BY r.name;
            """);

        Assert.Equal(MigratorDatabase.PlannedRoles.Order(), roles);
    }
}
