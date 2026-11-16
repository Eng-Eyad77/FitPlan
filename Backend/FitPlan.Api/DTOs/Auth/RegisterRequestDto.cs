using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Auth;

public class RegisterRequestDto
{
    [Required(ErrorMessage = "Enter a username.")]
    [StringLength(50, MinimumLength = 3, ErrorMessage = "Username must be 3 to 50 characters.")]
    public required string Username { get; set; }

    // The only password rule is its length (decision D3). The message says exactly that.
    [Required(ErrorMessage = "Enter a password.")]
    [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be 8 to 100 characters.")]
    public required string Password { get; set; }
}
