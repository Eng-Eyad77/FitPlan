using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class SessionExerciseConfiguration : IEntityTypeConfiguration<SessionExercise>
{
    public void Configure(EntityTypeBuilder<SessionExercise> builder)
    {
        //to link it to the table and put the condition to the table
        builder.ToTable("SessionExercises", table =>
        {
            table.HasCheckConstraint(
                "CK_SessionExercises_Order",
                "[Order] > 0");
        });

        //define the primary key
        builder.HasKey(p => p.Id);

        //the FK for the session (deleting the session deletes its exercises)
        builder.HasOne(p => p.WorkoutSession)
               .WithMany(p => p.Exercises)
               .HasForeignKey(p => p.WorkoutSessionId);

        // same decision as the plans: an exercise used in a session cannot be deleted
        builder.HasOne(p => p.Exercise)
               .WithMany()
               .HasForeignKey(p => p.ExerciseId)
               .OnDelete(DeleteBehavior.Restrict);

        // the same exercise only once per session
        builder.HasIndex(p => new { p.WorkoutSessionId, p.ExerciseId })
               .IsUnique();
    }
}
