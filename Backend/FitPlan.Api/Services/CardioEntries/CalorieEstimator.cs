using FitPlan.Api.Models;

namespace FitPlan.Api.Services.CardioEntries;

// Estimated calories burned. Always an ESTIMATE: even the machines themselves are not accurate.
//
// 1. Treadmill with a speed       -> ACSM metabolic equations (speed + incline + body weight), the most accurate we can do.
// 2. Rower or swimming with a pace -> a MET value picked from the pace (metres per minute).
// 3. Anything else                -> the moderate MET value of the activity × body weight × time.
//    Level, cadence, floors and stroke rate differ too much between machines to use, so they don't change it.
public static class CalorieEstimator
{
    // ACSM walking equation is valid up to about this speed, above it we use the running equation
    private const double WalkingMaxSpeedKmh = 6.5;

    public static int? Estimate(CardioEntry entry, decimal? bodyWeightKg) => Estimate(
        entry.Machine,
        entry.DurationSeconds,
        entry.SpeedKmh,
        entry.InclinePercent,
        entry.DistanceKm,
        entry.DistanceMeters,
        bodyWeightKg);

    public static int? Estimate(
        CardioMachine machine,
        int durationSeconds,
        decimal? speedKmh,
        decimal? inclinePercent,
        decimal? distanceKm,
        int? distanceMeters,
        decimal? bodyWeightKg)
    {
        // without the body weight there is no meaningful estimate
        if (bodyWeightKg is null)
        {
            return null;
        }

        var weightKg = (double)bodyWeightKg.Value;
        var minutes = durationSeconds / 60.0;

        // if the user gave the distance but not the speed, we can calculate the speed
        var speed = speedKmh is not null
            ? (double)speedKmh.Value
            : distanceKm is not null ? (double)distanceKm.Value / (durationSeconds / 3600.0) : (double?)null;

        double caloriesPerMinute;

        if (machine == CardioMachine.Treadmill && speed is > 0)
        {
            var metersPerMinute = speed.Value * 1000 / 60;
            var grade = (double)(inclinePercent ?? 0) / 100;

            // oxygen consumption (ml/kg/min)
            var vo2 = speed.Value <= WalkingMaxSpeedKmh
                ? 0.1 * metersPerMinute + 1.8 * metersPerMinute * grade + 3.5   // walking
                : 0.2 * metersPerMinute + 0.9 * metersPerMinute * grade + 3.5;  // running

            // 1 liter of oxygen ≈ 5 kcal
            caloriesPerMinute = vo2 * weightKg / 1000 * 5;
        }
        else
        {
            var pace = distanceMeters is > 0 ? distanceMeters.Value / minutes : (double?)null;
            caloriesPerMinute = GetMet(machine, pace) * 3.5 * weightKg / 200;
        }

        return (int)Math.Round(caloriesPerMinute * minutes);
    }


    // Values from the Compendium of Physical Activities. [pace] is in metres per minute, null when unknown.
    public static double GetMet(CardioMachine machine, double? pace = null) => machine switch
    {
        CardioMachine.Treadmill => 5.0,       // no speed given: assume brisk walking
        CardioMachine.StationaryBike => 6.8,
        CardioMachine.Elliptical => 5.0,
        CardioMachine.StairClimber => 9.0,
        // rowing machine: light, moderate, vigorous (about 3:50 and 2:57 per 500 m as the limits)
        CardioMachine.Rower => pace switch
        {
            null => 7.0,
            < 130 => 4.8,
            < 170 => 7.0,
            _ => 8.5
        },
        // swimming laps: no distance = general swimming; then slow, moderate and fast freestyle
        CardioMachine.Swimming => pace switch
        {
            null => 6.0,
            < 30 => 5.8,
            < 45 => 8.3,
            _ => 9.8
        },
        _ => 5.0
    };
}
