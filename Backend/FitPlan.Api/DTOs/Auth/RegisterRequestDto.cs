using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Auth;

public class RegisterRequestDto
{
    [Required(ErrorMessage = "Enter your email.")]
    [StringLength(254)]
    [EmailAddress(ErrorMessage = "Enter a valid email.")]
    public required string Email { get; set; }

    // the 6-digit code sent to the email
    [Required(ErrorMessage = "Enter the code from the email.")]
    [StringLength(10)]
    public required string Code { get; set; }

    // No "@", so the sign-in field can tell a username from an email (D18).
    [Required(ErrorMessage = "Enter a username.")]
    [StringLength(50, MinimumLength = 3, ErrorMessage = "Username must be 3 to 50 characters.")]
    [RegularExpression("^[^@]*$", ErrorMessage = "Username can't contain @.")]
    public required string Username { get; set; }

    // The only password rule is its length (decision D3). The message says exactly that.
    [Required(ErrorMessage = "Enter a password.")]
    [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be 8 to 100 characters.")]
    public required string Password { get; set; }
}
