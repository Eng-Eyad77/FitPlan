
namespace FitPlan.Api.Common.Results;

// Code    -> stable identifier the client (Flutter) can switch on, e.g. "WorkoutPlanNotFound"
// Message -> human readable description
// Type    -> decides the HTTP status code
public sealed record Error(string Code, string Message, ErrorType Type);
