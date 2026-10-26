
using FitPlan.Api.Data;
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
        var allExercises = await context.Exercises.ToListAsync();

        return Ok(allExercises);
        
    }
}
