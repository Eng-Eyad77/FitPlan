using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class BodyWeightEntryConfiguration : IEntityTypeConfiguration<BodyWeightEntry>
{
    public void Configure(EntityTypeBuilder<BodyWeightEntry> builder)
    {
        //to link it to the table and put the condition to the table
        builder.ToTable("BodyWeightEntries", table =>
        {
            table.HasCheckConstraint(
                "CK_BodyWeightEntries_WeightKg",
                "[WeightKg] >= 20 AND [WeightKg] <= 400");
        });

        //define the primary key
        builder.HasKey(p => p.Id);

        // ex: 78.50
        builder.Property(p => p.WeightKg)
               .HasPrecision(5, 2);

        builder.Property(p => p.RecordedAt)
               .IsRequired();

        //the FK for the user (deleting the user deletes the weight history)
        builder.HasOne(p => p.User)
               .WithMany()
               .HasForeignKey(p => p.UserId);

        // to get the latest weight fast
        builder.HasIndex(p => new { p.UserId, p.RecordedAt });
    }
}
