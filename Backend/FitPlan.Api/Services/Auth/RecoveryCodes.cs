using System.Security.Cryptography;
using FitPlan.Api.Models;
using Microsoft.AspNetCore.Identity;

namespace FitPlan.Api.Services.Auth;

// A recovery code lets a user who forgot their password set a new one (decision D11: no email on accounts).
// It is 16 characters from an alphabet without look-alikes (no 0/O, 1/I), about 80 bits, shown once as
// XXXX-XXXX-XXXX-XXXX. Only a hash is stored, and each code works once.
public static class RecoveryCodes
{
    private const string Alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private const int Length = 16;

    public static string Generate()
    {
        var chars = new char[Length];
        for (var i = 0; i < Length; i++)
        {
            chars[i] = Alphabet[RandomNumberGenerator.GetInt32(Alphabet.Length)];
        }

        var code = new string(chars);
        return $"{code[..4]}-{code[4..8]}-{code[8..12]}-{code[12..]}";
    }

    // People type codes with spaces, dashes or lower case.
    public static string Normalize(string input) =>
        new(input.Where(char.IsLetterOrDigit).Select(char.ToUpperInvariant).ToArray());

    public static void Assign(User user, string code, DateTime now)
    {
        user.RecoveryCodeHash = new PasswordHasher<User>().HashPassword(user, Normalize(code));
        user.RecoveryCodeCreatedAt = now;
    }

    public static bool Matches(User user, string input) =>
        user.RecoveryCodeHash is { } hash
        && new PasswordHasher<User>().VerifyHashedPassword(user, hash, Normalize(input)) != PasswordVerificationResult.Failed;
}
