using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Auth;

public class ResetPasswordRequestDto
{
    [Required(ErrorMessage = "Enter your email.")]
    [StringLength(254)]
    [EmailAddress(ErrorMessage = "Enter a valid email.")]
    public required string Email { get; set; }

    [Required(ErrorMessage = "Enter the code from the email.")]
    [StringLength(10)]
    public required string Code { get; set; }

    // the same rule as sign-up (D3)
    [Required(ErrorMessage = "Enter a new password.")]
    [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be 8 to 100 characters.")]
    public required string NewPassword { get; set; }
}
