
using FitPlan.Api.DTOs.Exercises;
using FitPlan.Api.Services.Exercises;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[ApiController]
[Route("api/exercises")]
public class ExercisesController(IExerciseService exerciseService) : ControllerBase
{
  [HttpGet]
  public async Task<IActionResult> GetAllExercises
  (int page = 1, // to point on 1 page
   int pageSize = 10, // to know how many exercises in the page 
   string? bodyPart = null, // wish body part
    string? search = null) // to search with exercise name
  {

    if (page < 1 || pageSize < 1 || pageSize > 100)
    {
      return BadRequest("Page must be at least 1, and pageSize must be between 1 and 100.");
    }

    return Ok(await exerciseService.GetAllExercisesAsync(page, pageSize, bodyPart, search));
    

  }



  [HttpGet("{id}")]
  public async Task<IActionResult> GetExerciseById(string id)
  {
    var exercise = await exerciseService.GetExerciseByIdAsync(id);

    if (exercise is null)
    {
      return NotFound();
    }

    return Ok(exercise);
  }
}
