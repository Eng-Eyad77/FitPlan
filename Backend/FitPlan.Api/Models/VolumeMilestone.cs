namespace FitPlan.Api.Models;

// A lifetime-volume milestone the user has reached (Phase 10). Once reached it stays, even if a
// workout is deleted later and the total drops below it. The total itself is never stored.
public class VolumeMilestone
{
    public required Guid UserId { get; set; }

    public User User { get; set; } = null!;

    // One of VolumeMilestones.All, for example "small-car".
    public required string Key { get; set; }

    // When the workout that crossed it was finished.
    public required DateTime ReachedAt { get; set; }
}
