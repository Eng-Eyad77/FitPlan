namespace FitPlan.Api.Extensions;

public static class UploadsExtensions
{
    // Where user uploads (profile pictures) are saved and served from under /uploads.
    // Locally: wwwroot/uploads. On Azure the deployed app folder can be read-only and is replaced on every
    // deploy, so production sets Uploads:Root to a folder outside it (e.g. D:\home\data\uploads).
    public static string GetUploadsRoot(this IConfiguration configuration, IWebHostEnvironment environment) =>
        configuration["Uploads:Root"] is { Length: > 0 } root
            ? root
            : Path.Combine(environment.ContentRootPath, "wwwroot", "uploads");
}
