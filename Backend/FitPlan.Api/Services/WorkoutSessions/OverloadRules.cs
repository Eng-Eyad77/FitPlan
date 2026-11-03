using FitPlan.Api.DTOs.WorkoutSessions;

namespace FitPlan.Api.Services.WorkoutSessions;

// Progressive overload ("double progression"): what to try today, from the last time (and the time before).
// Pure functions, no database, so every rule is easy to check.
public static class OverloadRules
{
    // last time's best set at the top weight under this share of the goal reps = a weak workout
    private const double WeakShare = 0.75;

    // the deload takes ~10% off the top weight
    private const decimal DeloadShare = 0.9m;

    public static SuggestionDto? Suggest(
        string name,
        string bodyPart,
        int? targetSets,
        int? targetReps,
        IReadOnlyList<SessionSetResponseDto> last,
        IReadOnlyList<SessionSetResponseDto>? previous)
    {
        if (last.Count == 0)
        {
            return null;
        }

        var weighted = last.Where(s => s.WeightKg > 0).ToList();

        // bodyweight: one more rep than the best set
        if (weighted.Count == 0)
        {
            return new SuggestionDto
            {
                Reps = last.Max(s => s.Reps) + 1,
                Reason = SuggestionReason.MoreReps
            };
        }

        var top = weighted.Max(s => s.WeightKg!.Value);
        var topSets = weighted.Where(s => s.WeightKg == top).ToList();
        // without a plan target, the goal is to repeat the best set across the sets
        var goal = targetReps ?? topSets.Max(s => s.Reps);
        var increment = IncrementFor(name, bodyPart);

        var hitEverything = topSets.Count >= (targetSets ?? 2) && topSets.All(s => s.Reps >= goal);
        if (hitEverything)
        {
            return new SuggestionDto
            {
                WeightKg = top + increment,
                Reps = goal,
                Reason = SuggestionReason.IncreaseWeight
            };
        }

        // two weak workouts in a row at this weight (or heavier): ease off and build back up
        if (IsWeak(topSets, goal) && previous is not null && WasWeakAtOrAbove(previous, top, goal))
        {
            var deload = Math.Round(top * DeloadShare / increment) * increment;
            return new SuggestionDto
            {
                WeightKg = Math.Max(increment, Math.Min(deload, top - increment)),
                Reps = goal,
                Reason = SuggestionReason.Deload
            };
        }

        return new SuggestionDto
        {
            WeightKg = top,
            Reps = goal,
            Reason = SuggestionReason.RepeatWeight
        };
    }

    // Plate steps by the kind of exercise. ExerciseDB has no equipment field, but its names start with it
    // ("barbell full squat", "dumbbell lateral raise").
    public static decimal IncrementFor(string name, string bodyPart)
    {
        var lowerName = name.ToLowerInvariant();
        var dumbbell = lowerName.StartsWith("dumbbell") || lowerName.StartsWith("kettlebell");

        if (IsIsolation(lowerName, bodyPart))
        {
            return dumbbell ? 1m : 2m;
        }

        if (dumbbell)
        {
            return 2m;
        }

        // big lower-body lifts move the most weight
        return bodyPart is "upper legs" ? 5m : 2.5m;
    }

    private static bool IsIsolation(string lowerName, string bodyPart)
    {
        if (bodyPart is "upper arms" or "lower arms" or "lower legs" or "neck" or "waist")
        {
            return true;
        }

        string[] isolationMoves = ["curl", "raise", "extension", "fly", "kickback", "pushdown", "pullover", "shrug"];
        return isolationMoves.Any(lowerName.Contains);
    }

    private static bool IsWeak(IReadOnlyList<SessionSetResponseDto> setsAtTop, int goal) =>
        setsAtTop.Max(s => s.Reps) < goal * WeakShare;

    private static bool WasWeakAtOrAbove(IReadOnlyList<SessionSetResponseDto> previous, decimal weight, int goal)
    {
        var weighted = previous.Where(s => s.WeightKg > 0).ToList();
        if (weighted.Count == 0)
        {
            return false;
        }

        var top = weighted.Max(s => s.WeightKg!.Value);
        return top >= weight && IsWeak(weighted.Where(s => s.WeightKg == top).ToList(), goal);
    }
}
