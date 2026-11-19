
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

    // Each machine takes only its own details (CardioFields); the others must be left out.
    [Range(1, 30)]
    public int? Level { get; set; }

    [Range(1, 1000)]
    public int? Floors { get; set; }

    [Range(20, 200)]
    public int? CadenceRpm { get; set; }

    [Range(10, 60)]
    public int? StrokeRate { get; set; }

    [Range(1, 50000)]
    public int? DistanceMeters { get; set; }

    [Range(10, 100)]
    public int? PoolLengthMeters { get; set; }

    [Range(1, 2000)]
    public int? Laps { get; set; }
}
