using System.Net;
using System.Net.Http.Headers;

namespace FitPlan.Api.Services.Exercises;

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

// Checks that a GIF link answers with a real GIF, reading only its first bytes. The media host drops
// HEAD requests and sometimes a connection, so it uses a small ranged GET and retries.
// Used by the migrator's check-gifs and by the admin (12C).
public static class GifLink
{
    private static readonly byte[] Gif87 = "GIF87a"u8.ToArray();
    private static readonly byte[] Gif89 = "GIF89a"u8.ToArray();

    public static async Task<(GifStatus Status, string Detail)> CheckAsync(
        HttpClient client, string url, CancellationToken cancellationToken = default, int attempts = 4)
    {
        var lastError = "";
        for (var attempt = 1; attempt <= attempts; attempt++)
        {
            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Get, url);
                request.Headers.Range = new RangeHeaderValue(0, 15);
                using var response = await client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, cancellationToken);

                if (response.StatusCode is HttpStatusCode.NotFound or HttpStatusCode.Forbidden or HttpStatusCode.Gone)
                {
                    return (GifStatus.Missing, $"HTTP {(int)response.StatusCode}");
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
                        ? (GifStatus.Works, "")
                        : (GifStatus.NotAGif, response.Content.Headers.ContentType?.MediaType ?? "no content type");
                }
            }
            catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException && !cancellationToken.IsCancellationRequested)
            {
                lastError = ex.InnerException?.Message ?? ex.Message;
            }

            if (attempt < attempts)
            {
                await Task.Delay(TimeSpan.FromSeconds(attempt), cancellationToken);
            }
        }

        return (GifStatus.Unreachable, lastError);
    }
}
