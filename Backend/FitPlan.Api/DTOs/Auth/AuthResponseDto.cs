namespace FitPlan.Api.DTOs.Auth;

public record class AuthResponseDto
(
    Guid Id,
    string Username,
    string AccessToken,
    // Added in Phase 5. Older app versions ignore these two fields.
    string RefreshToken,
    DateTime RefreshTokenExpiresAt,
    // Only after sign-up and a password reset: the new recovery code, shown to the user once.
    string? RecoveryCode = null
);
