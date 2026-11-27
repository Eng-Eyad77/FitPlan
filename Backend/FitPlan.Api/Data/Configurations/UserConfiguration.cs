using System;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        //to link it to the table
       builder.ToTable("Users", table =>
       {
           table.HasCheckConstraint(
               "CK_Users_WeeklyGoal",
               "[WeeklyGoal] IS NULL OR ([WeeklyGoal] >= 1 AND [WeeklyGoal] <= 7)");
       });


       //define the primary key
       builder.HasKey(p => p.Id);

        //the username Configurations
       builder.HasIndex(p => p.Username)
                .IsUnique();

       builder.Property(p => p.Username)
                            .IsRequired()
                            .HasMaxLength(50)
                            .UseCollation("SQL_Latin1_General_CP1_CI_AS"); // CI = Case Insensitive . Eyad = eyad = EYAD

        // the password Configurations
        builder.Property(p => p.PasswordHash)
                                .IsRequired();

        // shortcut: the D11 recovery-code columns stay, unused and empty, because the migrator can't drop columns yet; drop them when it can
        builder.Property<string?>("RecoveryCodeHash").HasMaxLength(200);
        builder.Property<DateTime?>("RecoveryCodeCreatedAt");

        // the email (254 is the longest an address can be)
        builder.HasIndex(p => p.Email)
                .IsUnique();

        builder.Property(p => p.Email)
                            .IsRequired()
                            .HasMaxLength(254);

        //the bio Configurations
        builder.Property(p => p.Bio)
                            .HasMaxLength(500);
        //the profilePictureUrl Configurations
        builder.Property(p => p.ProfilePictureUrl)
                            .HasMaxLength(500);
        //the CreatedAt Configurations
        builder.Property(p => p.CreatedAt)
                                .IsRequired();
        //the UpdatedAt Configurations
        builder.Property(p => p.UpdatedAt)
                                .IsRequired();
    }
}
