namespace FitPlan.Api.DTOs.Admin;

// 12E: totals only, no names of users. "Last 7 days" and "the 7 before" are rolling, counted in UTC.
public record AdminOverviewDto(
    DateTime CountedAt,
    int Users,
    int NewUsersLast7Days,
    int ActiveUsersLast7Days,
    int WorkoutsLast7Days,
    int WorkoutsPrevious7Days,
    decimal VolumeKgLast7Days,
    decimal VolumeKgPrevious7Days,
    int CardioEntriesThisMonth,
    string? MostUsedCardioMachine,
    // problems not marked done yet (suggestions not counted)
    int OpenReports,
    int ExercisesWithoutDemo,
    int EmailsToday,
    int EmailsPerDayLimit,
    // oldest day first; the last one is today
    IReadOnlyList<int> WorkoutsPerDay,
    // 7-day blocks, oldest first; the last one ends today
    IReadOnlyList<int> SignUpsPerWeek,
    IReadOnlyList<AdminExerciseUseDto> MostUsedExercises);

public record AdminExerciseUseDto(string Name, int Workouts);
