using System;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;


namespace FitPlan.Api.Data.Configurations;

public class WorkoutPlanExerciseConfiguration :IEntityTypeConfiguration<WorkoutPlanExercise>
{
    public void Configure(EntityTypeBuilder<WorkoutPlanExercise> builder)
    {
        //to link it to the table and put the condition to the tables
        builder.ToTable("WorkoutPlanExercises", table =>
        {
                table.HasCheckConstraint(
                  "CK_WorkoutPlanExercises_Sets",
                 "[Sets] >= 1 AND [Sets] <= 4");

                table.HasCheckConstraint(
                  "CK_WorkoutPlanExercises_Reps",
                  "[Reps] >= 1 AND [Reps] <= 20");

                 table.HasCheckConstraint(
                  "CK_WorkoutPlanExercises_Order",
                  "[Order] > 0");
        });

        //define the primary key
       builder.HasKey(p => p.Id);


           //the FK for workout plan and configuration
        builder.HasOne(p => p.WorkoutPlan)
               .WithMany()
               .HasForeignKey(p => p.WorkoutPlanId);


        builder.HasOne(p => p.Exercise)
                .WithMany()
                .HasForeignKey(p => p.ExerciseId)
                .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(p => new { p.WorkoutPlanId, p.ExerciseId })
                .IsUnique();
    }
}
