using Amazon.Runtime;
using Amazon.S3;
using Amazon.S3.Model;

namespace FitPlan.Api.Services.Exercises;

// Where uploaded exercise GIFs go. They are served from the storage's own public address, never
// through the API, so viewing them costs the free App Service plan nothing.
public interface IGifStorage
{
    // false when the storage isn't set up for this environment
    bool Configured { get; }

    // Saves the file under [key] and returns its public address.
    Task<string> SaveAsync(string key, byte[] gif, CancellationToken cancellationToken);
}

// Cloudflare R2 through its S3 API. Settings (section "Media"): R2AccountId, R2AccessKeyId,
// R2SecretAccessKey, Bucket and PublicBaseUrl. The key and secret live only in the App Service
// settings, never in the repository.
public sealed class R2GifStorage : IGifStorage, IDisposable
{
    private readonly AmazonS3Client? client;
    private readonly string bucket = "";
    private readonly string publicBaseUrl = "";

    public R2GifStorage(IConfiguration configuration)
    {
        var media = configuration.GetSection("Media");
        var account = media["R2AccountId"];
        var keyId = media["R2AccessKeyId"];
        var secret = media["R2SecretAccessKey"];
        bucket = media["Bucket"] ?? "";
        publicBaseUrl = (media["PublicBaseUrl"] ?? "").TrimEnd('/');

        if (string.IsNullOrWhiteSpace(account) || string.IsNullOrWhiteSpace(keyId) || string.IsNullOrWhiteSpace(secret) ||
            bucket.Length == 0 || !publicBaseUrl.StartsWith("https://", StringComparison.Ordinal))
        {
            return;
        }

        client = new AmazonS3Client(new BasicAWSCredentials(keyId, secret), new AmazonS3Config
        {
            ServiceURL = $"https://{account}.r2.cloudflarestorage.com",
            AuthenticationRegion = "auto",
            ForcePathStyle = true,
            // R2 doesn't take every checksum header the SDK would add by itself
            RequestChecksumCalculation = RequestChecksumCalculation.WHEN_REQUIRED,
            ResponseChecksumValidation = ResponseChecksumValidation.WHEN_REQUIRED
        });
    }

    public bool Configured => client is not null;

    public async Task<string> SaveAsync(string key, byte[] gif, CancellationToken cancellationToken)
    {
        if (client is null)
        {
            throw new InvalidOperationException("GIF storage isn't set up.");
        }

        using var body = new MemoryStream(gif);
        await client.PutObjectAsync(new PutObjectRequest
        {
            BucketName = bucket,
            Key = key,
            InputStream = body,
            ContentType = "image/gif",
            DisablePayloadSigning = true,
            // the name holds the file's hash, so a file never changes under its address
            Headers = { CacheControl = "public, max-age=31536000, immutable" }
        }, cancellationToken);

        return $"{publicBaseUrl}/{key}";
    }

    public void Dispose() => client?.Dispose();
}
