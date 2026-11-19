using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class CardioEntryConfiguration : IEntityTypeConfiguration<CardioEntry>
{
    public void Configure(EntityTypeBuilder<CardioEntry> builder)
    {
        //to link it to the table and put the conditions to the table
        builder.ToTable("CardioEntries", table =>
        {
            table.HasCheckConstraint(
                "CK_CardioEntries_DurationSeconds",
                "[DurationSeconds] >= 1 AND [DurationSeconds] <= 18000"); // max 5 hours

            table.HasCheckConstraint(
                "CK_CardioEntries_SpeedKmh",
                "[SpeedKmh] > 0 AND [SpeedKmh] <= 30");

            table.HasCheckConstraint(
                "CK_CardioEntries_InclinePercent",
                "[InclinePercent] >= 0 AND [InclinePercent] <= 40");

            table.HasCheckConstraint(
                "CK_CardioEntries_DistanceKm",
                "[DistanceKm] > 0 AND [DistanceKm] <= 100");

            table.HasCheckConstraint(
                "CK_CardioEntries_EstimatedCalories",
                "[EstimatedCalories] >= 0");

            table.HasCheckConstraint(
                "CK_CardioEntries_Level",
                "[Level] >= 1 AND [Level] <= 30");

            table.HasCheckConstraint(
                "CK_CardioEntries_Floors",
                "[Floors] >= 1 AND [Floors] <= 1000");

            table.HasCheckConstraint(
                "CK_CardioEntries_CadenceRpm",
                "[CadenceRpm] >= 20 AND [CadenceRpm] <= 200");

            table.HasCheckConstraint(
                "CK_CardioEntries_StrokeRate",
                "[StrokeRate] >= 10 AND [StrokeRate] <= 60");

            table.HasCheckConstraint(
                "CK_CardioEntries_DistanceMeters",
                "[DistanceMeters] >= 1 AND [DistanceMeters] <= 50000");

            table.HasCheckConstraint(
                "CK_CardioEntries_PoolLengthMeters",
                "[PoolLengthMeters] >= 10 AND [PoolLengthMeters] <= 100");

            table.HasCheckConstraint(
                "CK_CardioEntries_Laps",
                "[Laps] >= 1 AND [Laps] <= 2000");
        });

        //define the primary key
        builder.HasKey(p => p.Id);

        // stored as text ("Treadmill") so the table is readable
        builder.Property(p => p.Machine)
               .HasConversion<string>()
               .HasMaxLength(20);

        builder.Property(p => p.SpeedKmh)
               .HasPrecision(5, 2);

        builder.Property(p => p.InclinePercent)
               .HasPrecision(5, 2);

        builder.Property(p => p.DistanceKm)
               .HasPrecision(6, 2);

        //the FK for the session (deleting the session deletes its cardio)
        builder.HasOne(p => p.WorkoutSession)
               .WithMany(p => p.CardioEntries)
               .HasForeignKey(p => p.WorkoutSessionId);
    }
}
