using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Auth;

// Asks for a sign-up or password-reset code.
public class EmailRequestDto
{
    [Required(ErrorMessage = "Enter your email.")]
    [StringLength(254)]
    [EmailAddress(ErrorMessage = "Enter a valid email.")]
    public required string Email { get; set; }
}
