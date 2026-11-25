using System.ComponentModel.DataAnnotations;
using FitPlan.Api.Models;

namespace FitPlan.Api.DTOs.Admin;

public class AdminLoginRequestDto
{
    [Required(ErrorMessage = "Enter your email or username.")]
    [StringLength(254)]
    public required string Login { get; set; }

    [Required(ErrorMessage = "Enter your password.")]
    public required string Password { get; set; }

    // the 6 digits from the authenticator app
    [Required(ErrorMessage = "Enter the code from your authenticator app.")]
    [StringLength(10)]
    public required string Code { get; set; }
}

public record AdminSignInResponseDto(string Username, AdminRole Role, string AccessToken, DateTime ExpiresAt);

public record AdminMeDto(string Username, AdminRole Role);

public record AdminAuditEntryDto(long Id, string AdminName, string Action, string? Target, DateTime CreatedAt);
