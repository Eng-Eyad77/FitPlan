using System;
using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Profile;

public class UpdateProfileRequestDto
{
    [StringLength(500)]
    public string? Bio { get; set; }
        
}
