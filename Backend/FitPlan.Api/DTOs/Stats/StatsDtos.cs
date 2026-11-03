namespace FitPlan.Api.DTOs.Stats;

// ---------- overview (Progress tab header + weekly chart) ----------

public class StatsOverviewDto
{
    public int? WeeklyGoal { get; set; }

    // weeks in a row that reached the goal (or had at least 1 workout without a goal).
    // The current week counts once it is reached; while it is still open it does not break the streak.
    public int CurrentStreakWeeks { get; set; }

    public int TotalWorkouts { get; set; }

    public required WeekStatsDto ThisWeek { get; set; }

    public required WeekStatsDto LastWeek { get; set; }

    // oldest first, the last item is the current week
    public WeekStatsDto[] Weeks { get; set; } = [];
}

public class WeekStatsDto
{
    // first day of the week in the user's time zone
    public DateOnly WeekStart { get; set; }

    public int Workouts { get; set; }

    public int Sets { get; set; }

    public decimal VolumeKg { get; set; }

    public int CardioSeconds { get; set; }

    public int EstimatedCalories { get; set; }
}


// ---------- personal records ----------

public class ExerciseRecordsDto
{
    public required string ExerciseId { get; set; }

    public required string Name { get; set; }

    public required string GifUrl { get; set; }

    public required string BodyPart { get; set; }

    public DateTime LastPerformedAt { get; set; }

    // in how many completed workouts the exercise was done
    public int SessionCount { get; set; }

    // null for bodyweight-only exercises
    public RecordSetDto? HeaviestWeight { get; set; }

    // Epley formula, only from sets of 1-12 reps (beyond that the estimate is not reliable)
    public RecordSetDto? BestEstimated1Rm { get; set; }

    public required RecordSetDto MostReps { get; set; }

    // best weight × reps in a single set, null for bodyweight-only exercises
    public RecordSetDto? BestSetVolume { get; set; }
}

// The set that holds a record, and the record value it gives.
public class RecordSetDto
{
    public decimal Value { get; set; }

    public decimal? WeightKg { get; set; }

    public int Reps { get; set; }

    public Guid SessionId { get; set; }

    public DateTime AchievedAt { get; set; }
}


// ---------- one exercise over time (chart) ----------

public class ExerciseProgressDto
{
    public required ExerciseRecordsDto Records { get; set; }

    // oldest first
    public ExerciseSessionPointDto[] Sessions { get; set; } = [];
}

public class ExerciseSessionPointDto
{
    public Guid SessionId { get; set; }

    public DateTime PerformedAt { get; set; }

    // heaviest set of that workout (most reps wins a tie)
    public decimal? TopSetWeightKg { get; set; }

    public int TopSetReps { get; set; }

    public decimal? Estimated1Rm { get; set; }

    public decimal VolumeKg { get; set; }

    public int Sets { get; set; }
}


// ---------- this workout vs the previous one ----------

public class SessionComparisonDto
{
    public Guid SessionId { get; set; }

    // the previous completed workout of the same plan (or with the same name), null if none
    public Guid? PreviousSessionId { get; set; }

    public DateTime? PreviousPerformedAt { get; set; }

    public required ComparedValueDto VolumeKg { get; set; }

    public required ComparedValueDto Sets { get; set; }

    public required ComparedValueDto DurationSeconds { get; set; }

    public ExerciseComparisonDto[] Exercises { get; set; } = [];

    // records beaten in this workout (an exercise done for the first time sets no record)
    public NewRecordDto[] NewRecords { get; set; } = [];
}

public class ComparedValueDto
{
    public decimal Current { get; set; }

    public decimal? Previous { get; set; }
}

public class ExerciseComparisonDto
{
    public required string ExerciseId { get; set; }

    public required string Name { get; set; }

    public decimal? TopSetWeightKg { get; set; }

    public int TopSetReps { get; set; }

    // null when the previous workout did not have this exercise
    public decimal? PreviousTopSetWeightKg { get; set; }

    public int? PreviousTopSetReps { get; set; }

    public decimal VolumeKg { get; set; }

    public decimal? PreviousVolumeKg { get; set; }
}

public enum RecordType
{
    HeaviestWeight = 1,
    Estimated1Rm = 2,
    MostReps = 3,
    BestSetVolume = 4
}

public class NewRecordDto
{
    public required string ExerciseId { get; set; }

    public required string Name { get; set; }

    public RecordType Type { get; set; }

    public decimal Value { get; set; }

    public decimal PreviousBest { get; set; }
}
