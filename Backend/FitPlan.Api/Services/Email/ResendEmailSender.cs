using System.Net.Http.Headers;
using System.Net.Http.Json;

namespace FitPlan.Api.Services.Email;

// Sends through Resend's HTTP API (https://resend.com/docs/api-reference/emails/send-email).
// Email:ResendApiKey and Email:From come from App Settings; Email:ReplyTo is optional.
public class ResendEmailSender(HttpClient http, IConfiguration configuration, ILogger<ResendEmailSender> logger) : IEmailSender
{
    public async Task<bool> SendAsync(string to, EmailText text)
    {
        var replyTo = configuration["Email:ReplyTo"];
        using var request = new HttpRequestMessage(HttpMethod.Post, "emails")
        {
            Content = JsonContent.Create(new
            {
                from = configuration["Email:From"],
                to = new[] { to },
                subject = text.Subject,
                text = text.Body,
                reply_to = string.IsNullOrWhiteSpace(replyTo) ? null : replyTo
            })
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", configuration["Email:ResendApiKey"]);

        try
        {
            using var response = await http.SendAsync(request);
            if (response.IsSuccessStatusCode)
            {
                return true;
            }

            logger.LogError("Resend refused an email with status {Status}: {Body}",
                (int)response.StatusCode, await response.Content.ReadAsStringAsync());
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException)
        {
            logger.LogError(ex, "Could not reach Resend");
        }

        return false;
    }
}
