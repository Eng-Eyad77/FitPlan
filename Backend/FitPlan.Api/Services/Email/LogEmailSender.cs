namespace FitPlan.Api.Services.Email;

// Local runs without a Resend key: the email, code included, goes to the log. Never used on Dev or Production.
public class LogEmailSender(ILogger<LogEmailSender> logger) : IEmailSender
{
    public Task<bool> SendAsync(string to, EmailText text)
    {
        logger.LogInformation("Email to {To}: {Subject}\n{Body}", to, text.Subject, text.Body);
        return Task.FromResult(true);
    }
}
