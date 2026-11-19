using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Auth;

public class ResetPasswordRequestDto
{
    [Required(ErrorMessage = "Enter your username.")]
    [StringLength(50)]
    public required string Username { get; set; }

    [Required(ErrorMessage = "Enter your recovery code.")]
    [StringLength(40)]
    public required string RecoveryCode { get; set; }

    // the same rule as sign-up (D3)
    [Required(ErrorMessage = "Enter a new password.")]
    [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be 8 to 100 characters.")]
    public required string NewPassword { get; set; }
}
