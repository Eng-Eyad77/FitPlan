using System.Collections;
using FitPlan.Api.DTOs.Exercises;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace FitPlan.Api.Services.Exercises;

// Puts exercise names (and steps) in the request's language just before a response is written,
// so plans, workouts and stats show the same names as the library without each service doing it.
// The exercise library itself translates in ExerciseService, because its search needs the text.
public sealed class ExerciseLanguageFilter(ExerciseCatalog catalog) : IAsyncResultFilter
{
    public async Task OnResultExecutionAsync(ResultExecutingContext context, ResultExecutionDelegate next)
    {
        var language = ContentLanguage.From(context.HttpContext.Request);
        if (language != ContentLanguage.English && context.Result is ObjectResult { Value: { } value })
        {
            var items = new List<ILocalizedExercise>();
            Collect(value, items);
            if (items.Count > 0)
            {
                var snapshot = await catalog.GetAsync(context.HttpContext.RequestAborted);
                foreach (var item in items)
                {
                    catalog.Localize(snapshot, item, language);
                }
            }
        }

        // the same address answers in more than one language
        context.HttpContext.Response.Headers.Append("Vary", "Accept-Language");
        await next();
    }

    private static void Collect(object value, List<ILocalizedExercise> items)
    {
        switch (value)
        {
            case ILocalizedExercise item:
                items.Add(item);
                break;
            case IHasLocalizedExercises holder:
                items.AddRange(holder.LocalizedExercises);
                break;
            case IEnumerable list and not string:
                foreach (var element in list)
                {
                    if (element is not null)
                    {
                        Collect(element, items);
                    }
                }

                break;
        }
    }
}
