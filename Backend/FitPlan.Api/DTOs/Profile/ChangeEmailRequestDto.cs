using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Profile;

// Step 1 of an email change: the current password, and the new address that gets the code.
public class ChangeEmailRequestDto
{
    [Required(ErrorMessage = "Enter your new email.")]
    [StringLength(254)]
    [EmailAddress(ErrorMessage = "Enter a valid email.")]
    public required string NewEmail { get; set; }

    [Required(ErrorMessage = "Enter your password.")]
    [StringLength(100)]
    public required string Password { get; set; }
}

// Step 2: the code sent to the new address.
public class ConfirmEmailChangeDto
{
    [Required(ErrorMessage = "Enter the code from the email.")]
    [StringLength(10)]
    public required string Code { get; set; }
}
