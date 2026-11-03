using FitPlan.Api.DTOs.Stats;

namespace FitPlan.Api.Services.Stats;

// One logged set of a completed workout, flattened for the calculations.
public record SetRow(Guid SessionId, DateTime CompletedAt, string ExerciseId, int Reps, decimal? WeightKg);

// The record calculations. No database here, so they are easy to test.
public static class RecordMath
{
    // Epley is only reliable for low reps.
    public const int MaxRepsFor1Rm = 12;

    // Epley: weight × (1 + reps / 30). One rep = the weight itself.
    public static decimal? Estimated1Rm(decimal? weightKg, int reps)
    {
        if (weightKg is not > 0 || reps < 1 || reps > MaxRepsFor1Rm)
        {
            return null;
        }

        return reps == 1 ? weightKg.Value : Math.Round(weightKg.Value * (1 + reps / 30m), 1);
    }

    public static decimal Volume(decimal? weightKg, int reps) => reps * (weightKg ?? 0);

    public static RecordSetDto? HeaviestWeight(IEnumerable<SetRow> sets) =>
        Best(sets.Where(s => s.WeightKg > 0), s => s.WeightKg!.Value, s => s.Reps);

    public static RecordSetDto? BestEstimated1Rm(IEnumerable<SetRow> sets) =>
        Best(sets.Where(s => Estimated1Rm(s.WeightKg, s.Reps) != null), s => Estimated1Rm(s.WeightKg, s.Reps)!.Value, s => 0);

    public static RecordSetDto? MostReps(IEnumerable<SetRow> sets) =>
        Best(sets, s => s.Reps, s => s.WeightKg ?? 0);

    public static RecordSetDto? BestSetVolume(IEnumerable<SetRow> sets) =>
        Best(sets.Where(s => s.WeightKg > 0), s => Volume(s.WeightKg, s.Reps), s => 0);

    // The highest value wins; a tie goes to the better [tieBreak], then to the FIRST time it was done
    // (that is when the record was set).
    private static RecordSetDto? Best(
        IEnumerable<SetRow> sets,
        Func<SetRow, decimal> value,
        Func<SetRow, decimal> tieBreak)
    {
        var best = sets
            .OrderByDescending(value)
            .ThenByDescending(tieBreak)
            .ThenBy(s => s.CompletedAt)
            .FirstOrDefault();

        return best is null
            ? null
            : new RecordSetDto
            {
                Value = value(best),
                WeightKg = best.WeightKg,
                Reps = best.Reps,
                SessionId = best.SessionId,
                AchievedAt = best.CompletedAt
            };
    }

    // The heaviest set of one workout (most reps wins a tie). Bodyweight sets count as 0 kg.
    public static SetRow TopSet(IEnumerable<SetRow> sets) =>
        sets.OrderByDescending(s => s.WeightKg ?? 0).ThenByDescending(s => s.Reps).First();

    // Records in [current] that beat [before]. Nothing when [before] is empty: a first time is a baseline.
    public static IEnumerable<(RecordType Type, decimal Value, decimal PreviousBest)> NewRecords(
        IReadOnlyCollection<SetRow> current,
        IReadOnlyCollection<SetRow> before)
    {
        if (current.Count == 0 || before.Count == 0)
        {
            yield break;
        }

        var checks = new (RecordType Type, Func<IEnumerable<SetRow>, RecordSetDto?> Calculate)[]
        {
            (RecordType.HeaviestWeight, HeaviestWeight),
            (RecordType.Estimated1Rm, BestEstimated1Rm),
            (RecordType.MostReps, MostReps),
            (RecordType.BestSetVolume, BestSetVolume)
        };

        foreach (var (type, calculate) in checks)
        {
            var now = calculate(current);
            var previous = calculate(before);

            if (now is not null && previous is not null && now.Value > previous.Value)
            {
                yield return (type, now.Value, previous.Value);
            }
        }
    }

    // First day of the week that contains [localDate].
    public static DateOnly WeekStart(DateOnly localDate, DayOfWeek weekStartsOn)
    {
        var daysSinceStart = ((int)localDate.DayOfWeek - (int)weekStartsOn + 7) % 7;
        return localDate.AddDays(-daysSinceStart);
    }
}
