namespace FitPlan.Api.Models;

// One shared word in another language: an equipment or a muscle, as the source names it in English.
// Every exercise that uses the term shows the same word.
public class TermTranslation
{
    // "equipment" or "muscle"
    public required string Kind { get; set; }

    public required string Term { get; set; }

    public required string Language { get; set; }

    public required string Text { get; set; }
}
