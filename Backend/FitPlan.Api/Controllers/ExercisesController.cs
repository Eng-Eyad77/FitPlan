
using System.ComponentModel.DataAnnotations;
using FitPlan.Api.Services.Exercises;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;

[Route("api/exercises")]
public class ExercisesController(IExerciseService exerciseService) : ApiControllerBase
{
    // [ApiController] validates these [Range] attributes automatically
    // and returns 400 ValidationProblemDetails if they are out of range.
    [HttpGet]
    public async Task<IActionResult> GetAllExercises
    (
        [Range(1, int.MaxValue)] int page = 1, // to point on 1 page
        [Range(1, 100)] int pageSize = 10, // to know how many exercises in the page
        string? bodyPart = null, // wish body part
        string? search = null // to search with exercise name
    )
    {
        return Ok(await exerciseService.GetAllExercisesAsync(page, pageSize, bodyPart, search));
    }


    [HttpGet("{id}")]
    public async Task<IActionResult> GetExerciseById(string id)
    {
        var result = await exerciseService.GetExerciseByIdAsync(id);

        return result.IsSuccess ? Ok(result.Data) : Problem(result.Error);
    }
}
