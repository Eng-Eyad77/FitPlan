namespace FitPlan.Api.DTOs.Auth;

public record class AuthResponseDto
(
    Guid Id,
    string Username,
    string AccessToken
);
