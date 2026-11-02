
namespace FitPlan.Api.Extensions;

public static class ApplicationBuilderExtensions
{
    public static WebApplication ConfigureApplication(
        this WebApplication app)
    {
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
