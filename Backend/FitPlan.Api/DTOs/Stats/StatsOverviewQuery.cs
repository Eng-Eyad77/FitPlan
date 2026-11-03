using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Stats;

// The weeks are the user's weeks: the app sends its time zone and first day of the week,
// so a workout at 1 am on Saturday is not counted in Friday's week.
public class StatsOverviewQuery
{
    // how many weeks the chart shows, the current one included
    [Range(1, 52)]
    public int Weeks { get; set; } = 12;

    // e.g. +180 for Saudi Arabia (UTC+3)
    [Range(-840, 840)]
    public int UtcOffsetMinutes { get; set; }

    [EnumDataType(typeof(DayOfWeek))]
    public DayOfWeek WeekStartsOn { get; set; } = DayOfWeek.Sunday;
}
