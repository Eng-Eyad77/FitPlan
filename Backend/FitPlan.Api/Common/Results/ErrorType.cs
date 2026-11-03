
namespace FitPlan.Api.Common.Results;

// Describes the kind of failure, so the controller layer can map it to an HTTP status code.
public enum ErrorType
{
    Validation,
    Unauthorized,
    NotFound,
    Conflict,
    PayloadTooLarge
}
