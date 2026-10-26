using FitPlan.Api.Data;
using FitPlan.Api.DTOs.Exercises.External;
using FitPlan.Api.Models;
using FitPlan.Api.Services.Exercises;


namespace FitPlan.Api.Services.Exercises;

public class ExerciseImportService(IHttpClientFactory httpClientFactory, FitPlanDbContext context) : IExerciseImportService
{
    public async Task ImportExercisesAsync()
    {
        // to extract httpClient with our configuration
        var client = httpClientFactory.CreateClient("ExerciseDB");


        HttpResponseMessage? response; // the response that came from the Http
        ExerciseDbResponseDto? result; // the data after convert JSON to DTO
        List<Exercise> exercisesList = []; // all the exercises from all pages 
        string? nextCursor = null; // the pointer i use to point on new pages

        const int maxRetries = 3; // to know how many 

        do
        {

            string requestUrl = nextCursor is null
     ? "api/v1/exercises"
     : $"api/v1/exercises?after={nextCursor}";

            int retryAttempt = 0;

            while (true)
            {
                response = await client.GetAsync(requestUrl);

                if (response.StatusCode !=
                    System.Net.HttpStatusCode.TooManyRequests)
                {
                    break;
                }

                if (retryAttempt >= maxRetries)
                {
                      throw new HttpRequestException
                      (
                        $"ExerciseDB rate limit exceeded after {maxRetries} retries."
                      );
                }

                retryAttempt++;

                TimeSpan delay = GetRetryDelay(response, retryAttempt);

                if (delay > TimeSpan.FromSeconds(60))
                {
                    throw new InvalidOperationException(
                        $"Retry delay ({delay}) exceeds the allowed limit."
                    );
                }

                Console.WriteLine(
                    $"Rate limited. Retry {retryAttempt}/{maxRetries} after {delay}."
                );

                response.Dispose();

                await Task.Delay(delay);
            }


            // to make sure the response return 2-- ex: Ok 200
            response.EnsureSuccessStatusCode();

            result = await response.Content
       .ReadFromJsonAsync<ExerciseDbResponseDto>();


            if (result is null)
                throw new InvalidOperationException
                    (
                    "ExerciseDB returned an empty response."
                    );

            if (result.Meta is null)
                throw new InvalidOperationException
                    (
                    "ExerciseDB returned an empty response."
                    );

            if (result.Data is [])
            {
                throw new InvalidOperationException
                (
                "ExerciseDB returned an empty response."
                );
            }


            exercisesList.AddRange
            (
                result.Data.Select(item =>
        {
            if (item.BodyParts.Count == 0)
            {
                throw new InvalidOperationException(
                    $"Exercise {item.ExerciseId} has no body part."
                );
            }

            return new Exercise
            {
                Id = item.ExerciseId,
                Name = item.Name,
                GifUrl = item.GifUrl,
                BodyPart = item.BodyParts.First(),
                Instructions = item.Instructions
            };
        }).ToList()
            );


            if (result.Meta.HasNextPage)
            {
                if (string.IsNullOrWhiteSpace(result.Meta.NextCursor))
                {
                    throw new InvalidOperationException(
                        "ExerciseDB indicates more pages exist but returned no cursor."
                    );
                }

                nextCursor = result.Meta.NextCursor;
                Console.WriteLine($"Next cursor: {nextCursor}");
            }


        } while (result.Meta.HasNextPage);

        await context.AddRangeAsync(exercisesList);
        await context.SaveChangesAsync();
    }



//this for Calculate the waiting time ex: 10sec , 3sec.
    private static TimeSpan GetRetryDelay(
    HttpResponseMessage response,
    int retryAttempt)
    {
        var retryAfter = response.Headers.RetryAfter;

        if (retryAfter?.Delta is TimeSpan delay)
        {
            return delay > TimeSpan.Zero
                ? delay
                : TimeSpan.FromSeconds(1);
        }

        if (retryAfter?.Date is DateTimeOffset retryDate)
        {
            var remaining = retryDate - DateTimeOffset.UtcNow;

            return remaining > TimeSpan.Zero
                ? remaining
                : TimeSpan.FromSeconds(1);
        }

        // Exponential backoff if Retry-After is missing.
        var fallbackSeconds = Math.Min(
            2 * Math.Pow(2, retryAttempt - 1),
            60
        );

        return TimeSpan.FromSeconds(fallbackSeconds);
    }
}