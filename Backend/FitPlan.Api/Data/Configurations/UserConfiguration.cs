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
       builder.ToTable("Users");


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
