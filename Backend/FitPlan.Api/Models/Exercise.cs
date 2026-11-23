namespace FitPlan.Api.Models;

public class Exercise
{
    public required string Id { get; set; }

    public required string Name { get; set; }

    public required string GifUrl { get; set; }

    public required string BodyPart { get; set; }

    public required List<string> Instructions { get; set; }

    // Phase 11C: details from the source, as its English terms. Empty until the details are imported.
    public List<string> Equipments { get; set; } = [];

    public List<string> TargetMuscles { get; set; } = [];

    public List<string> SecondaryMuscles { get; set; } = [];
}
