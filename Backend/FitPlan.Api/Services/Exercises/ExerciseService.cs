using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Exercises;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.Exercises;

public class ExerciseService(FitPlanDbContext context) : IExerciseService
{
    public async Task<ExerciseListResponseDto> GetAllExercisesAsync
    (
        int page, // to point on 1 page
        int pageSize,// to know how many exercises in the page
         string? bodyPart, // wish body part
          string? search // to search with exercise name
    )


    {

    var query = context.Exercises.AsQueryable();

    if(!string.IsNullOrWhiteSpace(search))

    {
     // to bring the name == the search
    query = query.Where(e => e.Name.Contains(search));  
    }
    
    if(!string.IsNullOrWhiteSpace(bodyPart))
    {
      // to bring the exercises that match the body part selected
      query = query.Where(b => b.BodyPart.Contains(bodyPart));
    }
    //to calculate the exercises so i can divided on pages
    var totalCount = await query.CountAsync();


    // this is for put the exercises in pages 
    var exercises = await query
    .OrderBy(o => o.Id)
    .Skip((page - 1) * pageSize)
    .Take(pageSize)
    .Select(item => new ExerciseDto
     {
       Id = item.Id,
       Name = item.Name,
       BodyPart = item.BodyPart,
       GifUrl = item.GifUrl,
       Instructions = item.Instructions
      })
    .ToListAsync();

    var totalPages = (int)Math.Ceiling((double)totalCount/pageSize);

    return new ExerciseListResponseDto
    {
      Items = exercises,
      Page = page,
      PageSize = pageSize,
      TotalCount = totalCount,
      TotalPages = totalPages
    };
    }

    public async Task<ExerciseDto?> GetExerciseByIdAsync(string id)
    {
         var exercise = await context.Exercises.FindAsync(id);

    if (exercise is null)
    {
      return null;
    }

    return new ExerciseDto
    {
      Id = exercise.Id,
      Name = exercise.Name,
      BodyPart = exercise.BodyPart,
      GifUrl = exercise.GifUrl,
      Instructions = exercise.Instructions
    };
    }
}
