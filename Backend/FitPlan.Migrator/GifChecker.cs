using System.Net;
using System.Net.Http.Headers;

namespace FitPlan.Migrator;

public enum GifStatus
{
    Works,

    // the host answered that the file isn't there (404, 403, 410)
    Missing,

    // the host answered, but not with a GIF
    NotAGif,

    // no answer after every retry: unknown, so it's checked again rather than called broken
    Unreachable
}

public sealed record GifResult(ExerciseRow Exercise, GifStatus Status, string Detail);

// Checks that every exercise's GIF link answers with a real GIF. Reads only the first bytes of each file.
// The media host drops HEAD requests and sometimes a connection, so it uses a small ranged GET and retries.
public static class GifChecker
{
    private static readonly byte[] Gif87 = "GIF87a"u8.ToArray();
    private static readonly byte[] Gif89 = "GIF89a"u8.ToArray();

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
        var lastError = "";
        for (var attempt = 1; attempt <= 4; attempt++)
        {
            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Get, row.GifUrl);
                request.Headers.Range = new RangeHeaderValue(0, 15);
                using var response = await client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, cancellationToken);

                if (response.StatusCode is HttpStatusCode.NotFound or HttpStatusCode.Forbidden or HttpStatusCode.Gone)
                {
                    return new GifResult(row, GifStatus.Missing, $"HTTP {(int)response.StatusCode}");
                }

                if (!response.IsSuccessStatusCode)
                {
                    lastError = $"HTTP {(int)response.StatusCode}";
                }
                else
                {
                    var head = new byte[6];
                    await using var body = await response.Content.ReadAsStreamAsync(cancellationToken);
                    var read = await body.ReadAtLeastAsync(head, head.Length, throwOnEndOfStream: false, cancellationToken);
                    return read == head.Length && (head.SequenceEqual(Gif87) || head.SequenceEqual(Gif89))
                        ? new GifResult(row, GifStatus.Works, "")
                        : new GifResult(row, GifStatus.NotAGif, response.Content.Headers.ContentType?.MediaType ?? "no content type");
                }
            }
            catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException && !cancellationToken.IsCancellationRequested)
            {
                lastError = ex.InnerException?.Message ?? ex.Message;
            }

            await Task.Delay(TimeSpan.FromSeconds(attempt), cancellationToken);
        }

        return new GifResult(row, GifStatus.Unreachable, lastError);
    }
}
