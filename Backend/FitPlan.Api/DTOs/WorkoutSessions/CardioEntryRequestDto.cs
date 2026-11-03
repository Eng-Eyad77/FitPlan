
using System.ComponentModel.DataAnnotations;
using FitPlan.Api.Models;

namespace FitPlan.Api.DTOs.WorkoutSessions;

// Used for both adding and updating a cardio entry.
public class CardioEntryRequestDto
{
    // nullable + [Required] so a missing machine is rejected instead of silently becoming 0.
    // [EnumDataType] rejects values that are not in the enum.
    [Required]
    [EnumDataType(typeof(CardioMachine))]
    public CardioMachine? Machine { get; set; }

    [Range(1, 18000)] // up to 5 hours
    public int DurationSeconds { get; set; }

    // optional details
    [Range(0.1, 30.0)]
    public decimal? SpeedKmh { get; set; }

    [Range(0.0, 40.0)]
    public decimal? InclinePercent { get; set; }

    [Range(0.01, 100.0)]
    public decimal? DistanceKm { get; set; }
}
