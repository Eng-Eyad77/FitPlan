namespace FitPlan.Api.Models;

// Phase 12 (D10): only Owner exists for now. Admin, ContentEditor and Support come when a second person is added.
public enum AdminRole
{
    Owner = 1
}

// A user who may use the admin. Created only by the migrator's make-owner command, never by sign-up.
public class AdminAccount
{
    public required Guid UserId { get; set; }

    public User User { get; set; } = null!;

    public required AdminRole Role { get; set; }

    // shortcut: the authenticator secret is stored as plain Base32; encrypt it if anyone but the owner gets database access
    public required string TotpSecret { get; set; }

    // The last 30-second step a code was accepted for, so the same code can't be used twice.
    public long? LastTotpStep { get; set; }

    public required DateTime CreatedAt { get; set; }
}
