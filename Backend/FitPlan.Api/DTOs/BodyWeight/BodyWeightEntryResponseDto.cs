
namespace FitPlan.Api.DTOs.BodyWeight;

public class BodyWeightEntryResponseDto
{
    public Guid Id { get; set; }

    public decimal WeightKg { get; set; }

    public DateTime RecordedAt { get; set; }
}
