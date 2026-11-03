
using FitPlan.Api.Models;

namespace FitPlan.Api.Services.CardioEntries;

// Estimated calories burned. Always an ESTIMATE: even the machines themselves are not accurate.
//
// 1. Treadmill with a speed  -> ACSM metabolic equations (speed + incline + body weight), the most accurate we can do.
// 2. Anything else           -> MET value of the activity × body weight × time.
public static class CalorieEstimator
{
    // ACSM walking equation is valid up to about this speed, above it we use the running equation
    private const double WalkingMaxSpeedKmh = 6.5;

    public static int? Estimate(
        CardioMachine machine,
        int durationSeconds,
        decimal? speedKmh,
        decimal? inclinePercent,
        decimal? distanceKm,
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
            caloriesPerMinute = GetMet(machine) * 3.5 * weightKg / 200;
        }

        return (int)Math.Round(caloriesPerMinute * minutes);
    }


    // moderate intensity values from the Compendium of Physical Activities
    private static double GetMet(CardioMachine machine) => machine switch
    {
        CardioMachine.Treadmill => 5.0,       // no speed given: assume brisk walking
        CardioMachine.StationaryBike => 6.8,
        CardioMachine.Elliptical => 5.0,
        CardioMachine.StairClimber => 9.0,
        CardioMachine.Rower => 7.0,
        _ => 5.0
    };
}
