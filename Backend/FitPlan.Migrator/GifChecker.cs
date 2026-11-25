using FitPlan.Api.Services.Exercises;

namespace FitPlan.Migrator;

public sealed record GifResult(ExerciseRow Exercise, GifStatus Status, string Detail);

// Checks that every exercise's GIF link answers with a real GIF. Reads only the first bytes of each file.
public static class GifChecker
{
    public static async Task<IReadOnlyList<GifResult>> CheckAsync(
        HttpClient client, IReadOnlyList<ExerciseRow> rows, Action<int> progress, int parallel = 4, CancellationToken cancellationToken = default)
    {
        var results = new GifResult[rows.Count];
        var done = 0;

        await Parallel.ForAsync(0, rows.Count, new ParallelOptions { MaxDegreeOfParallelism = parallel, CancellationToken = cancellationToken },
            async (index, token) =>
            {
                results[index] = await CheckOneAsync(client, rows[index], token);
                var count = Interlocked.Increment(ref done);
                if (count % 100 == 0 || count == rows.Count)
                {
                    progress(count);
                }
            });

        return results;
    }

    private static async Task<GifResult> CheckOneAsync(HttpClient client, ExerciseRow row, CancellationToken cancellationToken)
    {
        var (status, detail) = await GifLink.CheckAsync(client, row.GifUrl, cancellationToken);
        return new GifResult(row, status, detail);
    }
}
