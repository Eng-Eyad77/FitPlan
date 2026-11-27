using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Auth;

public class LoginRequestDto
{
    // the email or the username (D18)
    [Required(ErrorMessage = "Enter your email or username.")]
    [StringLength(254)]
    public required string Login { get; set; }

    [Required(ErrorMessage = "Enter your password.")]
    public required string Password { get; set; }
}
