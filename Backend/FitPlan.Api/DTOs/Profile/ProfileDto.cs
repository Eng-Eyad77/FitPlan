
namespace FitPlan.Api.DTOs.Profile;

public class ProfileDto
{
    public required Guid Id { get; set; }

    public required string Username { get; set; }

    public string? Bio  { get; set; }

    public string? ProfilePictureUrl { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

}
