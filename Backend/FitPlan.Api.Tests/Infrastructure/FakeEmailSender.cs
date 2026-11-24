using System.Collections.Concurrent;
using System.Text.RegularExpressions;
using FitPlan.Api.Services.Email;

namespace FitPlan.Api.Tests.Infrastructure;

// Keeps every email instead of sending it. Set Fail to make sending fail.
public sealed class FakeEmailSender : IEmailSender
{
    private readonly ConcurrentDictionary<string, ConcurrentQueue<EmailText>> sent = new();

    public bool Fail { get; set; }

    public Task<bool> SendAsync(string to, EmailText text)
    {
        if (Fail)
        {
            return Task.FromResult(false);
        }

        sent.GetOrAdd(to, _ => new()).Enqueue(text);
        return Task.FromResult(true);
    }

    public IReadOnlyList<EmailText> To(string email) =>
        sent.TryGetValue(email.ToLowerInvariant(), out var queue) ? [.. queue] : [];

    // the code in the newest email to the address (the API sends to the lower-case address)
    public string LastCode(string email) =>
        Regex.Match(To(email)[^1].Body, @"\b\d{6}\b").Value;
}
