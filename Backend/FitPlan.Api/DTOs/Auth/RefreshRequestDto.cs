using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Auth;

public class RefreshRequestDto
{
    [Required(ErrorMessage = "Enter the refresh token.")]
    [StringLength(200)]
    public required string RefreshToken { get; set; }
}
