using Microsoft.Net.Http.Headers;

namespace FitPlan.Api.Services.Exercises;

// The language the app asks for in Accept-Language. Exercise text exists in English and Arabic;
// anything else gets English.
public static class ContentLanguage
{
    public const string English = "en";
    public const string Arabic = "ar";

    public static string From(HttpRequest request)
    {
        IList<StringWithQualityHeaderValue> accepted;
        try
        {
            accepted = request.GetTypedHeaders().AcceptLanguage;
        }
        catch (FormatException)
        {
            return English;
        }

        foreach (var value in accepted.OrderByDescending(v => v.Quality ?? 1))
        {
            var tag = value.Value.Value ?? "";
            if (tag.StartsWith(Arabic, StringComparison.OrdinalIgnoreCase))
            {
                return Arabic;
            }

            if (tag.StartsWith(English, StringComparison.OrdinalIgnoreCase))
            {
                return English;
            }
        }

        return English;
    }
}
