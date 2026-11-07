using System.Security.Cryptography;
using System.Text;
using FitPlan.Api.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

namespace FitPlan.Migrator.Tests.Infrastructure;

// The idempotent script EF Core generates for the API, the same way `dotnet ef migrations script --idempotent` does.
public static class Scripts
{
    public const string InitialCreate = "20261011115825_InitialCreate";
    public const string AddWorkoutSessions = "20261103062255_AddWorkoutSessions";
    public const string AddUserWeeklyGoal = "20261103111630_AddUserWeeklyGoal";

    public static readonly KnownMigrations Known = KnownMigrations.FromApi();

    public static string Idempotent()
    {
        using var context = new FitPlanDbContext(new DbContextOptionsBuilder<FitPlanDbContext>()
            .UseSqlServer("Server=not-used")
            .Options);

        return context.GetService<IMigrator>().GenerateScript(options: MigrationsSqlGenerationOptions.Idempotent);
    }

    public static byte[] Bytes(string script) => Encoding.UTF8.GetBytes(script);

    public static string Sha256(string script) => Convert.ToHexString(SHA256.HashData(Bytes(script)));

    // Replaces exactly one known piece of the script, so a test can't pass because nothing changed.
    public static string ReplaceOnce(string script, string oldValue, string newValue)
    {
        var index = script.IndexOf(oldValue, StringComparison.Ordinal);
        if (index < 0 || script.IndexOf(oldValue, index + 1, StringComparison.Ordinal) >= 0)
        {
            throw new InvalidOperationException($"Expected exactly one occurrence of: {oldValue}");
        }

        return string.Concat(script.AsSpan(0, index), newValue, script.AsSpan(index + oldValue.Length));
    }
}
