using System.ComponentModel.DataAnnotations;

namespace FitPlan.Api.DTOs.Admin;

// 12B. Emails are masked ("s***@gmail.com") until an admin asks to see one, which is logged.
public record AdminUserRowDto(Guid Id, string Username, string Email, DateTime CreatedAt, DateTime? LastWorkoutAt, bool Disabled, bool IsAdmin);

public record AdminUserDetailDto(
    Guid Id,
    string Username,
    string Email,
    DateTime CreatedAt,
    DateTime? DisabledAt,
    bool IsAdmin,
    int Workouts,
    int Plans,
    int SignedInDevices,
    int Reports,
    DateTime? LastWorkoutAt);

public record AdminUserEmailDto(string Email);

public class AdminDeleteUserDto
{
    // the username typed out again
    [Required]
    [StringLength(50)]
    public required string Username { get; set; }
}
