
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Exercises;
using FitPlan.Api.Models;
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
    allExercises = await context.Exercises.Select(item => new ExerciseDto
    {
      Id = item.Id,
      Name = item.Name,
      BodyPart = item.BodyPart,
      GifUrl = item.GifUrl,
      Instructions = item.Instructions
    }).ToListAsync();


    return Ok(allExercises);


  }



  [HttpGet("{id}")]
  public async Task<IActionResult> GetExerciseById(string id)
  {
    var exercise = await context.Exercises.FindAsync(id);

    if (exercise is null)
    {
      return NotFound();
    }

    return Ok(new ExerciseDto
    {
      Id = exercise.Id,
      Name = exercise.Name,
      BodyPart = exercise.BodyPart,
      GifUrl = exercise.GifUrl,
      Instructions = exercise.Instructions
    });
  }
}
