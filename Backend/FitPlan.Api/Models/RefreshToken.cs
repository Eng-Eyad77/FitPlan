namespace FitPlan.Api.Models;

// A long-lived token that gets a new access token without the password. Only its SHA-256 hash is stored.
// Each use replaces it with a new one in the same family; reusing an old one revokes the whole family.
public class RefreshToken
{
    public required Guid Id { get; set; }

    public required Guid UserId { get; set; }

    public User User { get; set; } = null!;

    // Every token that came from one login shares this id.
    public required Guid FamilyId { get; set; }

    public required string TokenHash { get; set; }

    public required DateTime CreatedAt { get; set; }

    public required DateTime ExpiresAt { get; set; }

    // When it was exchanged for a new token.
    public DateTime? UsedAt { get; set; }

    public DateTime? RevokedAt { get; set; }
}
