using FitPlan.Api.Common.Results;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Models;

namespace FitPlan.Api.Services.CardioEntries;

// The details each machine shows on its display. Duration is always required; every detail is optional,
// but a detail that the machine doesn't have is refused (for example speed on the stairs).
public static class CardioFields
{
    public const int RowerMaxDamper = 10;

    // The JSON names, used in the error messages.
    private static readonly Dictionary<CardioMachine, string[]> Allowed = new()
    {
        [CardioMachine.Treadmill] = ["speedKmh", "inclinePercent", "distanceKm"],
        [CardioMachine.StairClimber] = ["level", "floors"],
        [CardioMachine.StationaryBike] = ["level", "distanceKm", "cadenceRpm"],
        [CardioMachine.Elliptical] = ["level", "distanceKm", "inclinePercent"],
        [CardioMachine.Rower] = ["distanceMeters", "level", "strokeRate"],
        [CardioMachine.Swimming] = ["distanceMeters", "poolLengthMeters", "laps"],
        // only for entries saved before Other was retired: what it had then
        [CardioMachine.Other] = ["speedKmh", "inclinePercent", "distanceKm"]
    };

    public static IReadOnlyList<string> For(CardioMachine machine) => Allowed[machine];

    // null when every given detail belongs to the machine and is in range for it
    public static Error? Check(CardioEntryRequestDto dto)
    {
        var machine = dto.Machine!.Value;
        var allowed = Allowed[machine];

        foreach (var (name, given) in Given(dto))
        {
            if (given && !allowed.Contains(name))
            {
                return new Error(
                    "CardioFieldNotAllowed",
                    $"{Label(machine)} doesn't record {name}.",
                    ErrorType.Validation);
            }
        }

        if (machine == CardioMachine.Rower && dto.Level > RowerMaxDamper)
        {
            return new Error("CardioFieldNotAllowed", $"The rower's damper goes from 1 to {RowerMaxDamper}.", ErrorType.Validation);
        }

        return null;
    }

    // Swimming: laps × pool length when the distance itself wasn't given.
    public static int? SwimDistanceMeters(CardioEntryRequestDto dto) =>
        dto.Machine == CardioMachine.Swimming && dto.DistanceMeters is null && dto.Laps is { } laps && dto.PoolLengthMeters is { } pool
            ? laps * pool
            : dto.DistanceMeters;

    private static IEnumerable<(string Name, bool Given)> Given(CardioEntryRequestDto dto) =>
    [
        ("speedKmh", dto.SpeedKmh is not null),
        ("inclinePercent", dto.InclinePercent is not null),
        ("distanceKm", dto.DistanceKm is not null),
        ("distanceMeters", dto.DistanceMeters is not null),
        ("level", dto.Level is not null),
        ("floors", dto.Floors is not null),
        ("cadenceRpm", dto.CadenceRpm is not null),
        ("strokeRate", dto.StrokeRate is not null),
        ("poolLengthMeters", dto.PoolLengthMeters is not null),
        ("laps", dto.Laps is not null)
    ];

    private static string Label(CardioMachine machine) => machine switch
    {
        CardioMachine.StairClimber => "The stair climber",
        CardioMachine.StationaryBike => "The bike",
        CardioMachine.Swimming => "Swimming",
        CardioMachine.Other => "Other",
        _ => $"The {machine.ToString().ToLowerInvariant()}"
    };
}
