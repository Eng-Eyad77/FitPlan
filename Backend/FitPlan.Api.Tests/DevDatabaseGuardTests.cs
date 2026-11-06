using FitPlan.Api.Data;
using FitPlan.Api.Extensions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting.Internal;
using Xunit;

namespace FitPlan.Api.Tests;

// These only read configuration. Nothing here opens a database connection, and no real Azure identity is used:
// signing in with the actual Managed Identity can only be checked on the Dev App Service.
public class DevDatabaseGuardTests
{
    private const string DevServer = "fitplan-sql-eyad-dev.database.windows.net";
    private const string DevDatabase = "FitPlanDb-dev";
    private const string OtherServer = "other-server.database.windows.net";

    private static string ManagedIdentityConnection(string server, string database) =>
        $"Server=tcp:{server},1433;Database={database};Authentication=Active Directory Managed Identity;Encrypt=True;";

    [Theory]
    [InlineData(DevServer, DevDatabase)]
    [InlineData("FITPLAN-SQL-EYAD-DEV.DATABASE.WINDOWS.NET", "fitplandb-dev")]
    public void Dev_starts_against_the_Dev_database(string server, string database)
    {
        var exception = Record.Exception(() => AddDatabase("Dev", ManagedIdentityConnection(server, database)));

        Assert.Null(exception);
    }

    [Theory]
    [InlineData(OtherServer, DevDatabase)]
    [InlineData(DevServer, "FitPlanDb")]
    [InlineData(DevServer + ".example.test", DevDatabase)]
    [InlineData("localhost", DevDatabase)]
    public void Dev_refuses_every_other_server_or_database(string server, string database)
    {
        var exception = Assert.Throws<InvalidOperationException>(
            () => AddDatabase("Dev", ManagedIdentityConnection(server, database)));

        Assert.Contains("Dev database", exception.Message);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    public void Dev_refuses_a_missing_connection_string(string? connectionString)
    {
        Assert.Throws<InvalidOperationException>(() => AddDatabase("Dev", connectionString));
    }

    [Theory]
    [InlineData("Production")]
    [InlineData("Development")]
    public void Other_environments_are_not_limited_to_the_Dev_database(string environment)
    {
        var exception = Record.Exception(
            () => AddDatabase(environment, ManagedIdentityConnection(OtherServer, "SomeDatabase")));

        Assert.Null(exception);
    }

    [Fact]
    public void Managed_Identity_connection_string_is_passed_to_EF_without_any_password()
    {
        using var provider = AddDatabase("Dev", ManagedIdentityConnection(DevServer, DevDatabase)).BuildServiceProvider();
        using var context = provider.GetRequiredService<FitPlanDbContext>();

        var connection = new SqlConnectionStringBuilder(context.Database.GetConnectionString());

        Assert.Equal(SqlAuthenticationMethod.ActiveDirectoryManagedIdentity, connection.Authentication);
        Assert.Empty(connection.UserID);
        Assert.Empty(connection.Password);
    }

    [Fact]
    public void The_real_API_startup_runs_the_guard()
    {
        // The default connection string points at this machine, so the Dev environment must refuse to start.
        using var factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder => builder.UseEnvironment("Dev"));

        var exception = Assert.Throws<InvalidOperationException>(() => factory.Server);

        Assert.Contains("Dev database", exception.Message);
    }

    private static ServiceCollection AddDatabase(string environmentName, string? connectionString)
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> { ["ConnectionStrings:FitPlanDb"] = connectionString })
            .Build();

        var services = new ServiceCollection();
        services.AddDatabase(configuration, new HostingEnvironment { EnvironmentName = environmentName });
        return services;
    }
}
