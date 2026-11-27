

namespace FitPlan.Api.Extensions;

public static class ApplicationBuilderExtensions
{
    public static WebApplication ConfigureApplication(
        this WebApplication app)
    {
        // Must be first, so it can catch exceptions thrown by everything after it.
        app.UseExceptionHandler();

        // Gives empty error responses (e.g. 401 from JWT, 404 for unknown routes) a ProblemDetails body.
        app.UseStatusCodePages();

        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
            app.MapOpenApi();

        }

        // Browsers need CORS for Flutter Web; the phone apps don't use it at all. Only the hosted admin
        // site in Cors:AdminOrigin may call, and locally and on Dev also localhost, where the admin can
        // run from your machine (D10, revised: the admin is hosted on Dev too).
        var adminOrigin = app.Configuration["Cors:AdminOrigin"]?.TrimEnd('/');
        var allowLocalhost = app.Environment.IsDevelopment() || app.Environment.IsEnvironment("Dev");
        if (allowLocalhost || !string.IsNullOrWhiteSpace(adminOrigin))
        {
            app.UseCors(policy => policy
                .SetIsOriginAllowed(origin => string.Equals(origin, adminOrigin, StringComparison.OrdinalIgnoreCase) ||
                    (allowLocalhost && Uri.TryCreate(origin, UriKind.Absolute, out var uri) && uri.IsLoopback))
                .AllowAnyHeader()
                .AllowAnyMethod());
        }

        app.UseHttpsRedirection();

        app.UseAuthentication();
        app.UseAuthorization();

        // after authentication, so a signed-in user is limited by account rather than IP
        app.UseRateLimiter();

        // Profile pictures are no longer public files under /uploads (F-04, closed in Phase 6): only
        // GET api/profile/me/picture serves them, to their signed-in owner.

        app.MapControllers();
        app.MapHealthEndpoints();

        return app;
    }
}
