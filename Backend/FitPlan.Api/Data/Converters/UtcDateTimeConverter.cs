
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace FitPlan.Api.Data.Converters;

// SQL Server's datetime2 does not store the "Kind" of a DateTime,
// so values read back come as DateTimeKind.Unspecified and are serialized without the "Z".
// A client (Flutter) then reads them as LOCAL time, which is wrong.
// This converter keeps the rule: everything is stored as UTC, and read back marked as UTC.
public sealed class UtcDateTimeConverter() : ValueConverter<DateTime, DateTime>(
    // to database: make sure the value is UTC
    value => value.Kind == DateTimeKind.Local ? value.ToUniversalTime() : value,
    // from database: mark the value as UTC
    value => DateTime.SpecifyKind(value, DateTimeKind.Utc));
