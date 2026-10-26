namespace FitPlan.Api.DTOs.Exercises;

public record class ExerciseDto
{
    public required string Id { get; set; }

    public required string Name { get; set; }

    public  required string GifUrl { get; set; }

    public  required string BodyPart { get; set; }

    public required string[] Instructions { get; set; }
}
