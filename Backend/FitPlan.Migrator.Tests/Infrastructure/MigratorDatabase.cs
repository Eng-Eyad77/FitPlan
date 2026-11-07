using FitPlan.Api.Data;
using FitPlan.Api.Tests.Infrastructure;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage;

namespace FitPlan.Migrator.Tests.Infrastructure;

// An empty throwaway database with a `fitplan-migrator` user, like the one planned for Dev.
public sealed class MigratorDatabase : IAsyncDisposable
{
    public static readonly string[] PlannedRoles = ["db_ddladmin", "db_datareader", "db_datawriter"];

    private MigratorDatabase(string connectionString, FitPlanDbContext context)
    {
        ConnectionString = connectionString;
        Context = context;
    }

    public string ConnectionString { get; }

    // Connects as the test server's admin, for setup and for checking results.
    public FitPlanDbContext Context { get; }

    public static async Task<MigratorDatabase> CreateAsync(params string[] roles)
    {
        var connectionString = TestDatabase.CreateUniqueConnectionString();
        var context = new FitPlanDbContext(new DbContextOptionsBuilder<FitPlanDbContext>().UseSqlServer(connectionString).Options);
        await context.GetService<IRelationalDatabaseCreator>().CreateAsync();

        var database = new MigratorDatabase(connectionString, context);
        await database.ExecuteAsync($"CREATE USER [{ScriptRunner.MigratorUser}] WITHOUT LOGIN WITH DEFAULT_SCHEMA = dbo;");
        foreach (var role in roles.Length == 0 ? PlannedRoles : roles)
        {
            await database.ExecuteAsync($"ALTER ROLE {role} ADD MEMBER [{ScriptRunner.MigratorUser}];");
        }

        return database;
    }

    public async Task ExecuteAsync(string sql)
    {
        await using var connection = new SqlConnection(ConnectionString);
        await connection.OpenAsync();
        await using var command = new SqlCommand(sql, connection);
        await command.ExecuteNonQueryAsync();
    }

    public async Task<List<string>> QueryAsync(string sql)
    {
        await using var connection = new SqlConnection(ConnectionString);
        await connection.OpenAsync();
        await using var command = new SqlCommand(sql, connection);
        await using var reader = await command.ExecuteReaderAsync();

        var values = new List<string>();
        while (await reader.ReadAsync())
        {
            values.Add(reader.IsDBNull(0) ? "" : reader.GetValue(0).ToString()!);
        }

        return values;
    }

    public Task<List<string>> HistoryAsync() => QueryAsync("""
        IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NOT NULL
            SELECT [MigrationId] FROM [__EFMigrationsHistory] ORDER BY [MigrationId];
        """);

    // Tables, columns, indexes, constraints and keys, sorted, so two databases can be compared.
    public async Task<List<string>> SchemaAsync() => (await QueryAsync("""
        SELECT CONCAT('column|', t.name, '|', c.name, '|', ty.name, '|', c.max_length, '|', c.precision, '|', c.scale, '|', c.is_nullable, '|', c.is_identity) COLLATE DATABASE_DEFAULT
        FROM sys.tables t JOIN sys.columns c ON c.object_id = t.object_id JOIN sys.types ty ON ty.user_type_id = c.user_type_id
        UNION ALL
        SELECT CONCAT('index|', OBJECT_NAME(i.object_id), '|', i.name, '|', i.type_desc, '|', i.is_unique, '|', i.is_primary_key, '|', i.filter_definition, '|',
            (SELECT STRING_AGG(CONCAT(COL_NAME(ic.object_id, ic.column_id), ':', ic.is_descending_key, ':', ic.is_included_column), ',') WITHIN GROUP (ORDER BY ic.key_ordinal, ic.column_id)
             FROM sys.index_columns ic WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id)) COLLATE DATABASE_DEFAULT
        FROM sys.indexes i JOIN sys.tables t ON t.object_id = i.object_id WHERE i.type > 0
        UNION ALL
        SELECT CONCAT('check|', OBJECT_NAME(parent_object_id), '|', name, '|', definition) COLLATE DATABASE_DEFAULT FROM sys.check_constraints
        UNION ALL
        SELECT CONCAT('default|', OBJECT_NAME(parent_object_id), '|', COL_NAME(parent_object_id, parent_column_id), '|', definition) COLLATE DATABASE_DEFAULT FROM sys.default_constraints
        UNION ALL
        SELECT CONCAT('foreign key|', name, '|', OBJECT_NAME(parent_object_id), '|', OBJECT_NAME(referenced_object_id), '|', delete_referential_action_desc) COLLATE DATABASE_DEFAULT FROM sys.foreign_keys
        """)).Order(StringComparer.Ordinal).ToList();

    public async ValueTask DisposeAsync()
    {
        SqlConnection.ClearAllPools();
        await Context.Database.EnsureDeletedAsync();
        await Context.DisposeAsync();
    }
}
