/* this record is for auth controller if the user created 
return true and his data otherwise return false and the error code*/
namespace FitPlan.Api.DTOs.Auth;

public record RegisterResult
(
    bool Succeeded,

    AuthResponseDto? Data,

    string? ErrorCode
);
