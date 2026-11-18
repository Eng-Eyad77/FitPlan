namespace FitPlan.Api.DTOs.Auth;

public record class AuthResponseDto
(
    Guid Id,
    string Username,
    string AccessToken,
    // Added in Phase 5. Older app versions ignore these two fields.
    string RefreshToken,
    DateTime RefreshTokenExpiresAt
);
