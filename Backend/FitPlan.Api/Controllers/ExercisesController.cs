
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Exercises;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Controllers;

[ApiController]
[Route("api/exercises")]
public class ExercisesController(FitPlanDbContext context) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAllExercises()
    {
        List<ExerciseDto> allExercises;
      allExercises = await context.Exercises.Select(item => new  ExerciseDto{
          Id = item.Id,
          Name =  item.Name,
           BodyPart =  item.BodyPart,
           GifUrl = item.GifUrl,
           Instructions = item.Instructions
    }).ToListAsync();


      return Ok(allExercises);
            

    }
}
