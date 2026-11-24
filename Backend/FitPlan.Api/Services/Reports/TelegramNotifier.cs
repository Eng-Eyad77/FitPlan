using System.Net.Http.Json;

namespace FitPlan.Api.Services.Reports;

public interface ITelegramNotifier
{
    // false when the message didn't go out; the reason is logged
    Task<bool> SendAsync(string text);
}

// Sends to the owner's chat through the Bot API (https://core.telegram.org/bots/api#sendmessage).
// Telegram:BotToken and Telegram:ChatId come from App Settings. Without them nothing is sent, and the
// API still starts: reports stay in the database either way.
public class TelegramNotifier(HttpClient http, IConfiguration configuration, ILogger<TelegramNotifier> logger) : ITelegramNotifier
{
    public async Task<bool> SendAsync(string text)
    {
        var token = configuration["Telegram:BotToken"];
        var chatId = configuration["Telegram:ChatId"];
        if (string.IsNullOrWhiteSpace(token) || string.IsNullOrWhiteSpace(chatId))
        {
            logger.LogWarning("Telegram isn't configured; the report was only saved");
            return false;
        }

        try
        {
            // plain text, so nothing a user writes is read as formatting
            // "./" because the token has a ":", which would otherwise make "bot123" read as a URL scheme
            using var response = await http.PostAsJsonAsync($"./bot{token}/sendMessage", new { chat_id = chatId, text });
            if (response.IsSuccessStatusCode)
            {
                return true;
            }

            logger.LogError("Telegram refused a message with status {Status}", (int)response.StatusCode);
        }
        catch (Exception ex)
        {
            // any failure here only means no Telegram message: the report is already saved
            // the exception text can hold the URL, which holds the token, so only its type is logged
            logger.LogError("Could not reach Telegram: {Error}", ex.GetType().Name);
        }

        return false;
    }
}
