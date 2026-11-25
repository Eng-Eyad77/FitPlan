using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class AdminAccountConfiguration : IEntityTypeConfiguration<AdminAccount>
{
    public void Configure(EntityTypeBuilder<AdminAccount> builder)
    {
        builder.ToTable("AdminAccounts");

        builder.HasKey(a => a.UserId);

        builder.Property(a => a.TotpSecret)
               .HasMaxLength(64)
               .IsRequired();

        // two sign-ins with the same code: the second save fails instead of both getting in
        builder.Property(a => a.LastTotpStep)
               .IsConcurrencyToken();

        // deleting the user's account ends their admin access too
        builder.HasOne(a => a.User)
               .WithOne()
               .HasForeignKey<AdminAccount>(a => a.UserId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}
