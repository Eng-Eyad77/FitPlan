namespace FitPlan.Api.Models;

public class Exercise
{
    public required string Id { get; set; }

    public required string Name { get; set; }

    public required string GifUrl { get; set; }

    public required string BodyPart { get; set; }

    public required List<string> Instructions { get; set; }
}
