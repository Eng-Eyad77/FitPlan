using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class ServerEventConfiguration : IEntityTypeConfiguration<ServerEvent>
{
    public void Configure(EntityTypeBuilder<ServerEvent> builder)
    {
        builder.ToTable("ServerEvents");

        builder.HasKey(e => e.Id);

        builder.Property(e => e.Kind)
               .HasConversion<string>()
               .HasMaxLength(20);

        builder.Property(e => e.Detail)
               .HasMaxLength(200)
               .IsRequired();

        builder.Property(e => e.Reason)
               .HasMaxLength(100)
               .IsRequired();

        builder.Property(e => e.RequestId)
               .HasMaxLength(64);

        builder.HasIndex(e => new { e.Kind, e.CreatedAt });
    }
}
