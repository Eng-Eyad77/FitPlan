using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class ProblemReportConfiguration : IEntityTypeConfiguration<ProblemReport>
{
    public void Configure(EntityTypeBuilder<ProblemReport> builder)
    {
        builder.ToTable("ProblemReports");

        builder.HasKey(r => r.Id);

        builder.Property(r => r.Message)
               .HasMaxLength(2000)
               .IsRequired();

        builder.Property(r => r.AppVersion)
               .HasMaxLength(32);

        builder.Property(r => r.Platform)
               .HasMaxLength(20);

        builder.Property(r => r.Language)
               .HasMaxLength(10)
               .IsRequired();

        // deleting the account deletes its reports (F-02)
        builder.HasOne(r => r.User)
               .WithMany()
               .HasForeignKey(r => r.UserId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(r => new { r.UserId, r.CreatedAt });
    }
}
