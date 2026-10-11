//using System.Text.Json;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitPlan.Api.Data.Configurations;

public class ExerciseConfiguration : IEntityTypeConfiguration<Exercise>
{
    public void Configure(EntityTypeBuilder<Exercise> builder)
    {
         //to link it to the table
       builder.ToTable("Exercises");

       //define the primary key
       builder.HasKey(p => p.Id);


        //the Name Configurations
        builder.Property(p => p.Name)
                            .IsRequired()
                            .HasMaxLength(100);

        //the GIF Configurations
        builder.Property(p => p.GifUrl)
                            .IsRequired();
                            

        //the BodyPart Configurations
        builder.Property(p => p.BodyPart)
                            .IsRequired();
                           
   
       // the Instructions Configurations
       builder.Property(p => p.Instructions)                     
               .IsRequired();
            //    .HasConversion(
            //     instructions => JsonSerializer.Serialize(instructions, (JsonSerializerOptions?)null),
            //     json => JsonSerializer.Deserialize<List<string>>(json, (JsonSerializerOptions?) null)
            //     ?? new List<string>()
            //    );             
    }
}
