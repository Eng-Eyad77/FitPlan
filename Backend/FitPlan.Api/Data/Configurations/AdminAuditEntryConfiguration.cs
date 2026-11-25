using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class AdminAuditEntryConfiguration : IEntityTypeConfiguration<AdminAuditEntry>
{
    public void Configure(EntityTypeBuilder<AdminAuditEntry> builder)
    {
        builder.ToTable("AdminAuditEntries");

        builder.HasKey(e => e.Id);

        builder.Property(e => e.AdminName)
               .HasMaxLength(50)
               .IsRequired();

        builder.Property(e => e.Action)
               .HasMaxLength(100)
               .IsRequired();

        builder.Property(e => e.Target)
               .HasMaxLength(200);

        builder.HasIndex(e => e.CreatedAt);
    }
}
