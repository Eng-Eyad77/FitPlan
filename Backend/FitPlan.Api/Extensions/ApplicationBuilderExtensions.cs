
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

        app.UseHttpsRedirection();

        app.UseAuthentication();
        app.UseAuthorization();

        app.UseStaticFiles();

        app.MapControllers();

        return app;
    }
}
