using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class SessionSetConfiguration : IEntityTypeConfiguration<SessionSet>
{
    public void Configure(EntityTypeBuilder<SessionSet> builder)
    {
        //to link it to the table and put the conditions to the table
        // (a CHECK passes when the value is NULL, so bodyweight sets are allowed)
        builder.ToTable("SessionSets", table =>
        {
            table.HasCheckConstraint(
                "CK_SessionSets_SetNumber",
                "[SetNumber] > 0");

            table.HasCheckConstraint(
                "CK_SessionSets_Reps",
                "[Reps] >= 1 AND [Reps] <= 100");

            table.HasCheckConstraint(
                "CK_SessionSets_WeightKg",
                "[WeightKg] >= 0 AND [WeightKg] <= 500");
        });

        //define the primary key
        builder.HasKey(p => p.Id);

        // up to 9999.99 kg, two decimals (ex: 62.50)
        builder.Property(p => p.WeightKg)
               .HasPrecision(6, 2);

        //the FK for the session exercise (deleting the exercise deletes its sets)
        builder.HasOne(p => p.SessionExercise)
               .WithMany(p => p.Sets)
               .HasForeignKey(p => p.SessionExerciseId);
    }
}
