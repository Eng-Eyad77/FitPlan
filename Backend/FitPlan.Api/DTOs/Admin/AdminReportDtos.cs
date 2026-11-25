namespace FitPlan.Api.DTOs.Admin;

// 12F. Reports name the user by username only; emails stay in Users, behind "Show".
public record AdminReportDto(
    int Id,
    string Username,
    string Message,
    bool IsSuggestion,
    string? Platform,
    string? AppVersion,
    string Language,
    bool SentToTelegram,
    DateTime CreatedAt,
    DateTime? DoneAt);

public record AdminReportCountsDto(int Open, int Suggestions, int Done);

public record AdminReportListDto(IReadOnlyList<AdminReportDto> Items, int Page, int TotalPages, AdminReportCountsDto Counts);

public record AdminApiErrorDto(DateTime CreatedAt, string Endpoint, string Error, string? RequestId);

public record AdminFailedSignInDto(string Account, string Reason, int Attempts, DateTime LastAt);

public record AdminErrorsDto(IReadOnlyList<AdminApiErrorDto> ApiErrors, IReadOnlyList<AdminFailedSignInDto> FailedSignIns);
