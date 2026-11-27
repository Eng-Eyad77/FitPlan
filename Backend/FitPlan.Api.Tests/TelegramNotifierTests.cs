using System.Net;
using FitPlan.Api.Services.Reports;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace FitPlan.Api.Tests;

// Real Telegram tokens look like "123456:ABC-xyz". The ":" once made the request path read as a URL scheme
// ("bot123456"), so every report on Dev failed with a 500.
public class TelegramNotifierTests
{
    private sealed class Recorder(HttpStatusCode status) : HttpMessageHandler
    {
        public Uri? Url;

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            Url = request.RequestUri;
            return Task.FromResult(new HttpResponseMessage(status));
        }
    }

    private static (TelegramNotifier, Recorder) Notifier(HttpStatusCode status = HttpStatusCode.OK)
    {
        var recorder = new Recorder(status);
        var http = new HttpClient(recorder) { BaseAddress = new Uri("https://api.telegram.org/") };
        var configuration = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Telegram:BotToken"] = "123456:ABC-xyz",
            ["Telegram:ChatId"] = "42"
        }).Build();
        return (new TelegramNotifier(http, configuration, NullLogger<TelegramNotifier>.Instance), recorder);
    }

    [Fact]
    public async Task A_token_with_a_colon_reaches_the_send_message_url()
    {
        var (notifier, recorder) = Notifier();

        Assert.True(await notifier.SendAsync("hello"));
        Assert.Equal("https://api.telegram.org/bot123456:ABC-xyz/sendMessage", recorder.Url!.ToString());
    }

    [Fact]
    public async Task A_refused_message_returns_false()
    {
        var (notifier, _) = Notifier(HttpStatusCode.BadRequest);

        Assert.False(await notifier.SendAsync("hello"));
    }
}
