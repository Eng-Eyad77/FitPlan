using System;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class WorkoutPlanConfiguration : IEntityTypeConfiguration<WorkoutPlan>
{
    public void Configure(EntityTypeBuilder<WorkoutPlan> builder)
    {

        //to link it to the table
        builder.ToTable("WorkoutPlans");

        //define the primary key
       builder.HasKey(p => p.Id);

       //the Name Configurations
        builder.Property(p => p.Name)
                            .IsRequired()
                            .HasMaxLength(100);


        // the description configuration
        builder.Property(p => p.Description)
                                .HasMaxLength(500);


        //the user id as FK and configuration
        builder.HasOne(p => p.User)
               .WithMany(u => u.WorkoutPlans)
               .HasForeignKey(p => p.UserId);



        //the Create at configuration
        builder.Property(p => p.CreatedAt)
                .IsRequired();

        //the Update at configuration
        builder.Property(p => p.UpdatedAt)
                .IsRequired();

    }
}
