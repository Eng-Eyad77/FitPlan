using System.Collections.Concurrent;
using FitPlan.Api.Services.Exercises;

namespace FitPlan.Api.Tests.Infrastructure;

// Keeps uploaded GIFs in memory instead of sending them to R2. Set Configured to false to act as an
// environment where upload isn't set up.
public sealed class FakeGifStorage : IGifStorage
{
    public const string BaseUrl = "https://media.example.test";

    public ConcurrentDictionary<string, byte[]> Saved { get; } = new();

    public bool Configured { get; set; } = true;

    public Task<string> SaveAsync(string key, byte[] gif, CancellationToken cancellationToken)
    {
        Saved[key] = gif;
        return Task.FromResult($"{BaseUrl}/{key}");
    }
}
