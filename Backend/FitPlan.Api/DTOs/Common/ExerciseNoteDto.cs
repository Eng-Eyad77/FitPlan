using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Common;

// The note on one exercise of a plan or of a workout. Empty or null removes it.
public class ExerciseNoteDto
{
    public const int MaxLength = 500;

    [StringLength(MaxLength)]
    public string? Note { get; set; }

    public string? Cleaned() => string.IsNullOrWhiteSpace(Note) ? null : Note.Trim();
}
