using FitPlan.Api.Extensions;

namespace FitPlan.Api.Services.Pictures;

// The one place profile pictures are written, read and deleted. They live in
// <Uploads:Root>/profile-pictures, outside the deployed folder, so a deploy doesn't remove them.
public sealed class ProfilePictureStorage(IConfiguration configuration, IWebHostEnvironment environment)
{
    public const string UrlPrefix = "/uploads/profile-pictures/";

    private static readonly byte[] JpegStart = [0xFF, 0xD8, 0xFF];
    private static readonly byte[] PngStart = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

    private string Folder => Path.Combine(configuration.GetUploadsRoot(environment), "profile-pictures");

    // The real type, read from the file's first bytes. The file name and declared type can lie.
    public static (string Extension, string ContentType)? DetectImage(ReadOnlySpan<byte> start)
    {
        if (start.StartsWith(PngStart))
        {
            return (".png", "image/png");
        }

        if (start.StartsWith(JpegStart))
        {
            return (".jpg", "image/jpeg");
        }

        return null;
    }

    // Saves the bytes under a new random name and returns the URL kept on the user.
    public async Task<string> SaveAsync(byte[] bytes, string extension, CancellationToken cancellationToken = default)
    {
        Directory.CreateDirectory(Folder);
        var fileName = $"{Guid.NewGuid()}{extension}";
        await File.WriteAllBytesAsync(Path.Combine(Folder, fileName), bytes, cancellationToken);
        return UrlPrefix + fileName;
    }

    // The file behind a stored URL, or null when it is gone. Only the file name is used,
    // so a URL can never point outside the pictures folder.
    public (string Path, string ContentType)? Find(string? pictureUrl)
    {
        if (string.IsNullOrWhiteSpace(pictureUrl))
        {
            return null;
        }

        var path = Path.Combine(Folder, Path.GetFileName(pictureUrl));
        if (!File.Exists(path))
        {
            return null;
        }

        var contentType = Path.GetExtension(path).Equals(".png", StringComparison.OrdinalIgnoreCase) ? "image/png" : "image/jpeg";
        return (path, contentType);
    }

    public void Delete(string? pictureUrl)
    {
        if (Find(pictureUrl) is { } file)
        {
            File.Delete(file.Path);
        }
    }
}
