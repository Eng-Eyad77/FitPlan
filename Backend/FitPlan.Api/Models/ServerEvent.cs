namespace FitPlan.Api.Models;

public enum ServerEventKind
{
    ApiError = 1,
    FailedSignIn = 2
}

// 12F: something that went wrong on the server, for the admin's Reports and errors screen. Kept 30 days.
// Holds no passwords, tokens, emails or exception messages: only where it happened and what kind it was.
public class ServerEvent
{
    public long Id { get; set; }

    public required ServerEventKind Kind { get; set; }

    // "POST /api/sessions/{id}/complete" for an error; the username, "Unknown account" or
    // "Rate limited" for a sign-in
    public required string Detail { get; set; }

    // the exception type, or why the sign-in was refused
    public required string Reason { get; set; }

    // the traceId the API sent back in the error response, so it can be found in the logs
    public string? RequestId { get; set; }

    public required DateTime CreatedAt { get; set; }
}
