using FitPlan.Api.Common.Results;
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

        if (!string.IsNullOrWhiteSpace(search))
        {
            // to bring the exercises that their name contains the search
            query = query.Where(e => e.Name.Contains(search));
        }

        if (!string.IsNullOrWhiteSpace(bodyPart))
        {
            // exact match, so "upper arms" does not also bring "lower arms"
            query = query.Where(e => e.BodyPart == bodyPart);
        }

        //to calculate the exercises so i can divided on pages
        var totalCount = await query.CountAsync();

        // with a search: the exact name first, then names that start with it, then the rest (shorter names first)
        var ordered = string.IsNullOrWhiteSpace(search)
            ? query.OrderBy(o => o.Id)
            : query
                .OrderBy(e => e.Name == search ? 0 : e.Name.StartsWith(search) ? 1 : 2)
                .ThenBy(e => e.Name.Length)
                .ThenBy(e => e.Id);

        // this is for put the exercises in pages
        var exercises = await ordered
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

        var totalPages = (int)Math.Ceiling((double)totalCount / pageSize);

        return new ExerciseListResponseDto
        {
            Items = exercises,
            Page = page,
            PageSize = pageSize,
            TotalCount = totalCount,
            TotalPages = totalPages
        };
    }

    public async Task<Result<ExerciseDto>> GetExerciseByIdAsync(string id)
    {
        var exercise = await context.Exercises.FindAsync(id);

        if (exercise is null)
        {
            return Result<ExerciseDto>.Failure(Errors.ExerciseNotFound);
        }

        return Result<ExerciseDto>.Success(new ExerciseDto
        {
            Id = exercise.Id,
            Name = exercise.Name,
            BodyPart = exercise.BodyPart,
            GifUrl = exercise.GifUrl,
            Instructions = exercise.Instructions
        });
    }
}
