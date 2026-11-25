using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Reports;

// The language comes from Accept-Language, like the rest of the API.
public class CreateProblemReportDto
{
    [Required(ErrorMessage = "Describe the problem.")]
    [StringLength(2000, MinimumLength = 10, ErrorMessage = "Write 10 to 2,000 characters.")]
    public required string Message { get; set; }

    [StringLength(32)]
    public string? AppVersion { get; set; }

    // "ios" or "android"
    [StringLength(20)]
    public string? Platform { get; set; }

    // an idea for the app instead of a problem (same screen, same Telegram chat)
    public bool IsSuggestion { get; set; }
}

public record ProblemReportCreatedDto(int Id);
