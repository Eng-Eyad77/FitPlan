namespace FitPlan.Api.Services.Email;

public interface IEmailSender
{
    // false when the email could not be handed over; the reason is logged
    Task<bool> SendAsync(string to, EmailText text);
}

public sealed record EmailText(string Subject, string Body);
