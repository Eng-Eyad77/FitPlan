using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class WorkoutSessionConfiguration : IEntityTypeConfiguration<WorkoutSession>
{
    public void Configure(EntityTypeBuilder<WorkoutSession> builder)
    {
        //to link it to the table
        builder.ToTable("WorkoutSessions");

        //define the primary key
        builder.HasKey(p => p.Id);

        //the Name Configurations
        builder.Property(p => p.Name)
                .IsRequired()
                .HasMaxLength(100);

        //the Notes Configurations
        builder.Property(p => p.Notes)
                .HasMaxLength(1000);

        //the StartedAt Configurations
        builder.Property(p => p.StartedAt)
                .IsRequired();

        // the user id as FK.
        // Restrict (NoAction) because SQL Server does not allow two cascade paths to the same table:
        // Users -> WorkoutPlans -> WorkoutSessions  AND  Users -> WorkoutSessions.
        // So when we add "delete account" later, its sessions must be deleted first.
        builder.HasOne(p => p.User)
               .WithMany()
               .HasForeignKey(p => p.UserId)
               .OnDelete(DeleteBehavior.Restrict);

        // deleting a plan keeps the history, it only removes the link
        builder.HasOne(p => p.WorkoutPlan)
               .WithMany()
               .HasForeignKey(p => p.WorkoutPlanId)
               .OnDelete(DeleteBehavior.SetNull);

        // for the history query (user sessions ordered by date)
        builder.HasIndex(p => new { p.UserId, p.CompletedAt });

        // the database itself guarantees only ONE in-progress session per user,
        // even if the user taps "start" twice at the same moment
        builder.HasIndex(p => p.UserId, "IX_WorkoutSessions_OneActivePerUser")
               .IsUnique()
               .HasFilter("[CompletedAt] IS NULL");
    }
}
