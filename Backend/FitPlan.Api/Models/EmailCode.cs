namespace FitPlan.Api.Models;

public enum EmailCodePurpose
{
    SignUp,
    ResetPassword,
    ChangeEmail
}

// One 6-digit code sent by email (D18). Rows also count the emails sent to an address, so they are
// kept for a day even after use. Only the newest row for an address and purpose can be used.
public class EmailCode
{
    public required Guid Id { get; set; }

    // lower case; for ChangeEmail it is the new address
    public required string Email { get; set; }

    public required EmailCodePurpose Purpose { get; set; }

    // set for ChangeEmail only
    public Guid? UserId { get; set; }

    // hex SHA-256 of the row id and the code; empty when no code was sent
    public required string CodeHash { get; set; }

    public int Attempts { get; set; }

    public required DateTime CreatedAt { get; set; }

    public required DateTime ExpiresAt { get; set; }

    public DateTime? UsedAt { get; set; }
}
