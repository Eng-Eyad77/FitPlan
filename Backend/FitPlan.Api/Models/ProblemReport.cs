namespace FitPlan.Api.Models;

// A problem a user reported from the app (D14). Saved first, then sent to the owner on Telegram.
public class ProblemReport
{
    // a short number to quote in replies ("report #12")
    public int Id { get; set; }

    public required Guid UserId { get; set; }

    public User User { get; set; } = null!;

    public required string Message { get; set; }

    public string? AppVersion { get; set; }

    public string? Platform { get; set; }

    public required string Language { get; set; }

    public required DateTime CreatedAt { get; set; }

    // an idea for the app rather than a problem
    public bool IsSuggestion { get; set; }

    // false when Telegram couldn't be reached; the report is still here
    public bool SentToTelegram { get; set; }

    // 12F: set when the admin marks it done; null = still open
    public DateTime? DoneAt { get; set; }
}
