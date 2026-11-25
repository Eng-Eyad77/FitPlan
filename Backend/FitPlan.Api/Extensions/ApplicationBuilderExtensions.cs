

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

        // Browsers need CORS for Flutter Web; the phone apps don't use it at all. Locally and on Dev
        // only localhost may call (the admin runs on your machine there, D10). Elsewhere only the admin
        // site in Cors:AdminOrigin, and nothing if it isn't set.
        var adminOrigin = app.Configuration["Cors:AdminOrigin"];
        if (app.Environment.IsDevelopment() || app.Environment.IsEnvironment("Dev"))
        {
            app.UseCors(policy => policy
                .SetIsOriginAllowed(origin => new Uri(origin).IsLoopback)
                .AllowAnyHeader()
                .AllowAnyMethod());
        }
        else if (!string.IsNullOrWhiteSpace(adminOrigin))
        {
            app.UseCors(policy => policy.WithOrigins(adminOrigin).AllowAnyHeader().AllowAnyMethod());
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
