
namespace FitPlan.Api.Common.Results;

public sealed class Result<T>
{
    public bool IsSuccess { get; init; }
    public T? Data { get; init; }
    public string? Error { get; init; }
    public string? ErrorCode { get; init; }


    private Result() { }


public static Result<T> Success(T data)
{
    return new Result<T>
    {
        IsSuccess = true,
        Data = data
    };
}

public static Result<T> Failure(string error, string errorCode)
{
    return new Result<T>
    {
        IsSuccess = false,
        Error = error,
        ErrorCode = errorCode
    };
}


}
