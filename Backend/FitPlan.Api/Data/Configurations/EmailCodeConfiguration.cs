using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class EmailCodeConfiguration : IEntityTypeConfiguration<EmailCode>
{
    public void Configure(EntityTypeBuilder<EmailCode> builder)
    {
        builder.ToTable("EmailCodes");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Email)
               .HasMaxLength(254)
               .IsRequired();

        builder.Property(c => c.Purpose)
               .HasConversion<string>()
               .HasMaxLength(20);

        builder.Property(c => c.CodeHash)
               .HasMaxLength(64)
               .IsRequired();

        // quota and lookups go by address and time; ChangeEmail looks up by user
        builder.HasIndex(c => new { c.Email, c.CreatedAt });

        builder.HasIndex(c => new { c.UserId, c.CreatedAt });
    }
}
