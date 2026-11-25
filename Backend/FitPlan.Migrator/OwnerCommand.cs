using FitPlan.Api.Services.Admin;
using Microsoft.Data.SqlClient;

namespace FitPlan.Migrator;

// Phase 12: the only way an admin is made. It needs your own database sign-in, so the public API
// can never create one. Run again to replace the authenticator secret (a lost phone): the old codes stop.
public static class OwnerCommand
{
    public sealed record Outcome(string? Username, string? Secret, string Message);

    public static async Task<Outcome> MakeOwnerAsync(string connectionString, string login, DateTime now)
    {
        if (!MigrationTarget.IsAllowed(connectionString, out var reason))
        {
            return new Outcome(null, null, $"Refused: {reason}");
        }

        await using var connection = new SqlConnection(new SqlConnectionStringBuilder(connectionString) { ApplicationName = "FitPlan.Migrator" }.ConnectionString);
        await connection.OpenAsync();
        await using var transaction = (SqlTransaction)await connection.BeginTransactionAsync();

        var find = new SqlCommand("SELECT Id, Username FROM Users WHERE Email = @email OR Username = @login", connection, transaction);
        find.Parameters.AddWithValue("@email", login.Trim().ToLowerInvariant());
        find.Parameters.AddWithValue("@login", login.Trim());
        Guid id;
        string username;
        await using (var reader = await find.ExecuteReaderAsync())
        {
            if (!await reader.ReadAsync())
            {
                return new Outcome(null, null, "No account has this email or username. Sign up in the app first. Nothing was changed.");
            }

            id = reader.GetGuid(0);
            username = reader.GetString(1);
        }

        var secret = Totp.NewSecret();
        var save = new SqlCommand("""
            MERGE AdminAccounts AS a
            USING (SELECT @id AS UserId) AS s ON a.UserId = s.UserId
            WHEN MATCHED THEN UPDATE SET TotpSecret = @secret, LastTotpStep = NULL
            WHEN NOT MATCHED THEN INSERT (UserId, Role, TotpSecret, LastTotpStep, CreatedAt) VALUES (@id, 1, @secret, NULL, @now);
            INSERT INTO AdminAuditEntries (AdminUserId, AdminName, Action, Target, CreatedAt)
            VALUES (@id, @username, N'Made owner, new authenticator secret', N'migrator', @now);
            """, connection, transaction);
        save.Parameters.AddWithValue("@id", id);
        save.Parameters.AddWithValue("@secret", secret);
        save.Parameters.AddWithValue("@username", username);
        save.Parameters.AddWithValue("@now", now);
        await save.ExecuteNonQueryAsync();
        await transaction.CommitAsync();

        return new Outcome(username, secret, $"{username} is the owner. Add the secret to your authenticator app.");
    }
}
