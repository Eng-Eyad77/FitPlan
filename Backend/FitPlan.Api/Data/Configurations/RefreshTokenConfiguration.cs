using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> builder)
    {
        builder.ToTable("RefreshTokens");

        builder.HasKey(t => t.Id);

        // hex SHA-256
        builder.Property(t => t.TokenHash)
               .HasMaxLength(64)
               .IsRequired();

        builder.HasIndex(t => t.TokenHash)
               .IsUnique();

        builder.HasIndex(t => t.FamilyId);

        builder.HasIndex(t => new { t.UserId, t.ExpiresAt });

        // deleting the user deletes their sessions
        builder.HasOne(t => t.User)
               .WithMany()
               .HasForeignKey(t => t.UserId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}
