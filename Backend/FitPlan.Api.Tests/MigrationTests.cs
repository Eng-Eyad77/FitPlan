using FitPlan.Api.Data;
using FitPlan.Api.Models;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage;
using Xunit;

namespace FitPlan.Api.Tests;

// Each test gets its own empty database, so nothing depends on the database the API tests share.
public sealed class MigrationTests : IAsyncLifetime
{
    private static readonly string[] ExpectedTables =
    [
        "BodyWeightEntries",
        "CardioEntries",
        "EmailCodes",
        "Exercises",
        "ExerciseTranslations",
        "RefreshTokens",
        "SessionExercises",
        "SessionSets",
        "TermTranslations",
        "Users",
        "VolumeMilestones",
        "WorkoutPlanExercises",
        "WorkoutPlans",
        "WorkoutSessions"
    ];

    private readonly FitPlanDbContext context = new(
        new DbContextOptionsBuilder<FitPlanDbContext>()
            .UseSqlServer(TestDatabase.CreateUniqueConnectionString())
            .Options);

    public Task InitializeAsync() => Task.CompletedTask;

    public async Task DisposeAsync()
    {
        await context.Database.EnsureDeletedAsync();
        await context.DisposeAsync();
    }

    [Fact]
    public async Task Migrations_build_every_table_on_an_empty_database()
    {
        await context.Database.MigrateAsync();

        Assert.Equal(context.Database.GetMigrations(), await context.Database.GetAppliedMigrationsAsync());
        Assert.Empty(await context.Database.GetPendingMigrationsAsync());

        var tables = await context.Database
            .SqlQueryRaw<string>("SELECT name AS [Value] FROM sys.tables WHERE name <> '__EFMigrationsHistory'")
            .ToListAsync();
        Assert.Equal(ExpectedTables, tables.Order());
    }

    [Fact]
    public void The_model_has_no_change_without_a_migration()
    {
        Assert.False(context.Database.HasPendingModelChanges());
    }

    [Fact]
    public async Task Running_the_migrations_again_changes_nothing()
    {
        await context.Database.MigrateAsync();
        var applied = (await context.Database.GetAppliedMigrationsAsync()).ToList();

        await context.Database.MigrateAsync();

        Assert.Equal(applied, await context.Database.GetAppliedMigrationsAsync());
    }

    [Fact]
    public async Task The_database_itself_allows_only_one_session_in_progress_per_user()
    {
        await context.Database.MigrateAsync();

        var user = new User
        {
            Id = Guid.NewGuid(),
            Username = ApiFixture.NewUsername(),
            Email = ApiFixture.NewEmail(),
            PasswordHash = "not-a-real-hash",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        context.Users.Add(user);
        context.WorkoutSessions.Add(NewSession(user.Id));
        await context.SaveChangesAsync();

        context.WorkoutSessions.Add(NewSession(user.Id));

        var exception = await Assert.ThrowsAsync<DbUpdateException>(() => context.SaveChangesAsync());
        Assert.True(exception.IsUniqueConstraintViolation());
    }

    // D18: accounts from before email are deleted with their workouts, which don't cascade from the user.
    [Fact]
    public async Task The_email_migration_deletes_the_accounts_without_an_email()
    {
        var migrator = context.GetService<IMigrator>();
        await migrator.MigrateAsync("20261123102033_AddExerciseDetailsAndTranslations");
        var userId = Guid.NewGuid();
        await context.Database.ExecuteSqlAsync($"""
            INSERT INTO [Users] ([Id], [Username], [PasswordHash], [CreatedAt], [UpdatedAt])
            VALUES ({userId}, {ApiFixture.NewUsername()}, N'not-a-real-hash', SYSUTCDATETIME(), SYSUTCDATETIME());
            INSERT INTO [WorkoutSessions] ([Id], [UserId], [Name], [StartedAt])
            VALUES ({Guid.NewGuid()}, {userId}, N'Old session', SYSUTCDATETIME());
            """);

        await context.Database.MigrateAsync();

        Assert.Equal(0, await context.Users.CountAsync());
        Assert.Equal(0, await context.WorkoutSessions.CountAsync());
    }

    [Fact]
    public async Task Every_migration_can_be_rolled_back_and_applied_again()
    {
        var migrator = context.GetService<IMigrator>();
        await context.Database.MigrateAsync();

        await migrator.MigrateAsync(Migration.InitialDatabase);
        Assert.Empty(await context.Database.GetAppliedMigrationsAsync());

        await context.Database.MigrateAsync();
        Assert.Equal(context.Database.GetMigrations(), await context.Database.GetAppliedMigrationsAsync());
    }

    [Fact]
    public async Task Migrations_run_with_only_the_permissions_planned_for_schema_changes()
    {
        await context.GetService<IRelationalDatabaseCreator>().CreateAsync();
        await context.Database.OpenConnectionAsync();

        await context.Database.ExecuteSqlRawAsync("CREATE USER [fitplan-migrator] WITHOUT LOGIN WITH DEFAULT_SCHEMA = dbo;");
        await context.Database.ExecuteSqlRawAsync("ALTER ROLE db_ddladmin ADD MEMBER [fitplan-migrator];");
        await context.Database.ExecuteSqlRawAsync("ALTER ROLE db_datareader ADD MEMBER [fitplan-migrator];");
        await context.Database.ExecuteSqlRawAsync("ALTER ROLE db_datawriter ADD MEMBER [fitplan-migrator];");

        await context.Database.ExecuteSqlRawAsync("EXECUTE AS USER = 'fitplan-migrator';");
        try
        {
            await context.Database.MigrateAsync();
        }
        finally
        {
            await context.Database.ExecuteSqlRawAsync("REVERT;");
        }

        Assert.Equal(context.Database.GetMigrations(), await context.Database.GetAppliedMigrationsAsync());
    }

    private static WorkoutSession NewSession(Guid userId) => new()
    {
        Id = Guid.NewGuid(),
        UserId = userId,
        Name = "Test session",
        StartedAt = DateTime.UtcNow
    };
}
