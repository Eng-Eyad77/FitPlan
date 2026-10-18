using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Auth;

public class RegisterRequestDto
{

[StringLength(50)] [Required]
   public  required string  Username  { get; set; }

[Required]
   public required string Password { get; set; }
    
}
