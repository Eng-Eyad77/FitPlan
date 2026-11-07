using System.Reflection;
using FitPlan.Api.Data;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Migrator;

// The migrations compiled into the API, and the EF Core version that writes them into the history table.
public sealed record KnownMigrations(IReadOnlyList<string> Ids, string ProductVersion)
{
    public static KnownMigrations FromApi()
    {
        // No connection is opened: listing migrations only reads the compiled model.
        using var context = new FitPlanDbContext(new DbContextOptionsBuilder<FitPlanDbContext>()
            .UseSqlServer("Server=not-used")
            .Options);

        var version = typeof(DbContext).Assembly
            .GetCustomAttribute<AssemblyInformationalVersionAttribute>()!
            .InformationalVersion
            .Split('+')[0];

        return new KnownMigrations(context.Database.GetMigrations().ToList(), version);
    }
}
