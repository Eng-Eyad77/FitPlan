using System.Collections.Concurrent;
using FitPlan.Api.Services.Reports;

namespace FitPlan.Api.Tests.Infrastructure;

// Keeps every Telegram message instead of sending it. Set Fail to make sending fail.
public sealed class FakeTelegramNotifier : ITelegramNotifier
{
    public ConcurrentQueue<string> Sent { get; } = new();

    public bool Fail { get; set; }

    public Task<bool> SendAsync(string text)
    {
        if (Fail)
        {
            return Task.FromResult(false);
        }

        Sent.Enqueue(text);
        return Task.FromResult(true);
    }
}
