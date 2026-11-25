using System.Buffers.Binary;
using System.Security.Cryptography;

namespace FitPlan.Api.Services.Admin;

// Authenticator app codes (RFC 6238: HMAC-SHA1, 30-second steps, 6 digits), as Google and Microsoft
// Authenticator expect. Written here because it is a few lines and needs no package.
public static class Totp
{
    private const int StepSeconds = 30;
    private const string Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

    public static string NewSecret() => ToBase32(RandomNumberGenerator.GetBytes(20));

    public static long StepAt(DateTimeOffset time) => time.ToUnixTimeSeconds() / StepSeconds;

    // The step the code belongs to, allowing one step either side for a phone clock that is a little off.
    // null if it matches none, or only a step already used (afterStep).
    public static long? Match(string secret, string code, DateTimeOffset now, long? afterStep)
    {
        if (code.Length != 6 || !code.All(char.IsAsciiDigit))
        {
            return null;
        }

        var key = FromBase32(secret);
        var current = StepAt(now);
        for (var step = current - 1; step <= current + 1; step++)
        {
            if (step > (afterStep ?? long.MinValue)
                && CryptographicOperations.FixedTimeEquals(System.Text.Encoding.ASCII.GetBytes(Code(key, step, 6)), System.Text.Encoding.ASCII.GetBytes(code)))
            {
                return step;
            }
        }

        return null;
    }

    public static string Code(byte[] key, long step, int digits)
    {
        Span<byte> counter = stackalloc byte[8];
        BinaryPrimitives.WriteInt64BigEndian(counter, step);
        var hash = HMACSHA1.HashData(key, counter);
        var offset = hash[^1] & 0x0F;
        var value = BinaryPrimitives.ReadInt32BigEndian(hash.AsSpan(offset)) & 0x7FFFFFFF;
        return (value % (int)Math.Pow(10, digits)).ToString().PadLeft(digits, '0');
    }

    // What an authenticator app reads from a QR code, or from the secret typed in by hand.
    public static string SetupUri(string account, string secret) =>
        $"otpauth://totp/FitPlan%20Admin:{Uri.EscapeDataString(account)}?secret={secret}&issuer=FitPlan%20Admin";

    public static string ToBase32(byte[] bytes)
    {
        var output = new System.Text.StringBuilder();
        int buffer = 0, bits = 0;
        foreach (var b in bytes)
        {
            buffer = (buffer << 8) | b;
            bits += 8;
            while (bits >= 5)
            {
                output.Append(Alphabet[(buffer >> (bits - 5)) & 31]);
                bits -= 5;
            }
        }

        if (bits > 0)
        {
            output.Append(Alphabet[(buffer << (5 - bits)) & 31]);
        }

        return output.ToString();
    }

    public static byte[] FromBase32(string text)
    {
        var output = new List<byte>();
        int buffer = 0, bits = 0;
        foreach (var c in text.TrimEnd('='))
        {
            var value = Alphabet.IndexOf(char.ToUpperInvariant(c));
            if (value < 0)
            {
                throw new FormatException("The secret isn't Base32.");
            }

            buffer = (buffer << 5) | value;
            bits += 5;
            if (bits >= 8)
            {
                output.Add((byte)(buffer >> (bits - 8)));
                bits -= 8;
            }
        }

        return [.. output];
    }
}
