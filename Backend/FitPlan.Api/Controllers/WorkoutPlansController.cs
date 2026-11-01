
using System.Security.Claims;
using FitPlan.Api.DTOs.WorkoutPlans;
using FitPlan.Api.Services.WorkoutPlans;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitPlan.Api.Controllers;


[ApiController]
[Authorize]
[Route("api/workout-plans")]
public class WorkoutPlansController(IWorkoutPlanService workoutPlanService) : ControllerBase
{

    [HttpPost]
    public async Task<ActionResult> CreateWorkoutPlan([FromBody] CreateWorkoutPlanDto createWorkoutPlan)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }
       
       var newPlan = await workoutPlanService.CreateWorkoutPlanAsync(createWorkoutPlan, userId);
        if(newPlan is null)
        {
            return NotFound("User not found");
        }

        return CreatedAtAction
        (
            nameof(GetWorkoutPlanById),
            new { id = newPlan.Id },
            newPlan
        );


    }


    [HttpGet("{id:guid}")]
    public async Task<ActionResult> GetWorkoutPlanById(Guid id)
    {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var getWorkoutPlanById = await workoutPlanService.GetWorkoutPlanByIdAsync(userId, id);
            if(getWorkoutPlanById is null)
        {
            return NotFound("Plan not found");
        }

        return Ok(getWorkoutPlanById);

    }



    [HttpGet]
    public async Task<ActionResult> GetMyWorkoutPlans()
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var plans = await workoutPlanService.GetAllMyWorkoutPlansAsync(userId);
     
        return Ok(plans);
    }


   [HttpPut("{id:guid}")]
    public async Task<ActionResult> UpdateWorkoutPlan([FromBody]UpdateWorkoutPlanDto updateWorkoutPlan, Guid id)
    {
         var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }


        var updatedPlan = await workoutPlanService.UpdateWorkoutPlanAsync(userId, id, updateWorkoutPlan);
        if(updatedPlan is null)
        {
            return NotFound("There is no Plan to Update");
        }

        return Ok(updatedPlan);
    }



        [HttpDelete("{id:guid}")]
        public async Task<ActionResult> DeleteWorkoutPlan(Guid id)
    {
             var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var deletePlan = await workoutPlanService.DeleteWorkoutPlanAsync(id,userId);
        if(!deletePlan)
        {
            return NotFound("No Plan to Delete");
        }

        return NoContent();
    }
}
