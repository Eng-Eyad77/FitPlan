using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class ExerciseTranslationConfiguration : IEntityTypeConfiguration<ExerciseTranslation>
{
    public void Configure(EntityTypeBuilder<ExerciseTranslation> builder)
    {
        builder.ToTable("ExerciseTranslations");

        builder.HasKey(t => new { t.ExerciseId, t.Language });

        builder.Property(t => t.Language).HasMaxLength(10);
        builder.Property(t => t.Name).IsRequired().HasMaxLength(150);
        builder.Property(t => t.Instructions).IsRequired();

        builder.HasOne(t => t.Exercise)
            .WithMany()
            .HasForeignKey(t => t.ExerciseId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
