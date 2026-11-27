using FitPlan.Api.Models;
using FitPlan.Migrator.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Migrator.Tests;

// Phase 12: make-owner is the only way an admin is created.
public sealed class OwnerCommandTests
{
    [Fact]
    public async Task Makes_an_owner_then_replaces_the_secret_on_a_second_run()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        await database.Context.Database.MigrateAsync();
        var now = DateTime.UtcNow;
        database.Context.Users.Add(new User { Id = Guid.NewGuid(), Username = "eyad", Email = "eyad@example.test", PasswordHash = "x", CreatedAt = now, UpdatedAt = now });
        await database.Context.SaveChangesAsync();

        var first = await OwnerCommand.MakeOwnerAsync(database.ConnectionString, "EYAD@example.test", now);
        var second = await OwnerCommand.MakeOwnerAsync(database.ConnectionString, "eyad", now);

        var admin = await database.Context.AdminAccounts.AsNoTracking().SingleAsync();
        Assert.Equal(AdminRole.Owner, admin.Role);
        Assert.NotEqual(first.Secret, second.Secret);
        Assert.Equal(second.Secret, admin.TotpSecret);
        Assert.Equal(2, await database.Context.AdminAuditEntries.CountAsync());
    }

    [Fact]
    public async Task Changes_nothing_for_an_unknown_account()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        await database.Context.Database.MigrateAsync();

        var outcome = await OwnerCommand.MakeOwnerAsync(database.ConnectionString, "nobody", DateTime.UtcNow);

        Assert.Null(outcome.Secret);
        Assert.Empty(await database.Context.AdminAccounts.ToListAsync());
    }
}
