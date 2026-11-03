
using System.Diagnostics.CodeAnalysis;

namespace FitPlan.Api.Common.Results;

public sealed class Result<T>
{
    // MemberNotNullWhen lets the compiler know:
    // IsSuccess == true  -> Data is not null
    // IsSuccess == false -> Error is not null
    [MemberNotNullWhen(true, nameof(Data))]
    [MemberNotNullWhen(false, nameof(Error))]
    public bool IsSuccess { get; }

    public T? Data { get; }

    public Error? Error { get; }

    private Result(bool isSuccess, T? data, Error? error)
    {
        IsSuccess = isSuccess;
        Data = data;
        Error = error;
    }

    public static Result<T> Success(T data) => new(true, data, null);

    public static Result<T> Failure(Error error) => new(false, default, error);
}
