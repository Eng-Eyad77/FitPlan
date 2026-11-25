namespace FitPlan.Api.Models;

// One admin action. Never edited or deleted by the API, and kept when the admin's account goes,
// so it has no foreign key and keeps the name as it was.
public class AdminAuditEntry
{
    public long Id { get; set; }

    public required Guid AdminUserId { get; set; }

    public required string AdminName { get; set; }

    public required string Action { get; set; }

    // what it was done to, such as a username or an exercise id
    public string? Target { get; set; }

    public required DateTime CreatedAt { get; set; }
}
