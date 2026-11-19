using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Profile;

// The current password, asked again before something that can't be undone.
public class PasswordConfirmationDto
{
    [Required(ErrorMessage = "Enter your password.")]
    [StringLength(100)]
    public required string Password { get; set; }
}
