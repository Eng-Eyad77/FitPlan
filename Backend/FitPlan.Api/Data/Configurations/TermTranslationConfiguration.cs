using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class TermTranslationConfiguration : IEntityTypeConfiguration<TermTranslation>
{
    public void Configure(EntityTypeBuilder<TermTranslation> builder)
    {
        builder.ToTable("TermTranslations");

        builder.HasKey(t => new { t.Kind, t.Term, t.Language });

        builder.Property(t => t.Kind).HasMaxLength(20);
        builder.Property(t => t.Term).HasMaxLength(100);
        builder.Property(t => t.Language).HasMaxLength(10);
        builder.Property(t => t.Text).IsRequired().HasMaxLength(150);
    }
}
