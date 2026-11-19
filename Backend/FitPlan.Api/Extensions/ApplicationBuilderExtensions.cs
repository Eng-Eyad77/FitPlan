

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

            // Flutter Web runs on another localhost port, so the browser needs CORS to call the API.
            // Development only: the mobile apps do not use CORS at all.
            app.UseCors(policy => policy
                .SetIsOriginAllowed(origin => new Uri(origin).IsLoopback)
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
