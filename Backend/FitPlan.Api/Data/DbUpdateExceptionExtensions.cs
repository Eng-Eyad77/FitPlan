
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Data;

public static class DbUpdateExceptionExtensions
{
    // SQL Server error 2601 / 2627 = a row violated a unique index / unique constraint.
    // Used to catch duplicates that slipped through our checks because of concurrent requests.
    public static bool IsUniqueConstraintViolation(this DbUpdateException exception) =>
        exception.InnerException is SqlException { Number: 2601 or 2627 };
}
