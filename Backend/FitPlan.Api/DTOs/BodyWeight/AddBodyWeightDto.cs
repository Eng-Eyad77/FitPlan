
using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.BodyWeight;

public class AddBodyWeightDto
{
    [Range(20.0, 400.0)]
    public decimal WeightKg { get; set; }
}
