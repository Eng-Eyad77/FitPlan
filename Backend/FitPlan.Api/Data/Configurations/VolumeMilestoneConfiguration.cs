using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class VolumeMilestoneConfiguration : IEntityTypeConfiguration<VolumeMilestone>
{
    public void Configure(EntityTypeBuilder<VolumeMilestone> builder)
    {
        builder.ToTable("VolumeMilestones");

        // each milestone is reached once per user
        builder.HasKey(m => new { m.UserId, m.Key });

        builder.Property(m => m.Key)
               .HasMaxLength(32)
               .IsRequired();

        // deleting the user deletes their milestones
        builder.HasOne(m => m.User)
               .WithMany()
               .HasForeignKey(m => m.UserId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}
