using FitPlan.Api.Services.Auth;
using FitPlan.Api.Services.Profile;
using FitPlan.Api.Services.Exercises;
using FitPlan.Api.Services.WorkoutPlans;
using FitPlan.Api.Services.WorkoutPlanExercises;
using FitPlan.Api.Services.WorkoutSessions;
using FitPlan.Api.Services.SessionExercises;
using FitPlan.Api.Services.CardioEntries;
using FitPlan.Api.Services.BodyWeight;
using FitPlan.Api.Services.Stats;
using FitPlan.Api.Services.Pictures;
using FitPlan.Api.Services.Email;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace FitPlan.Api.Extensions;

public static class ServicesExtensions
{
    public static IServiceCollection AddApplicationServices(
        this IServiceCollection services, IConfiguration configuration, IHostEnvironment environment)
    {
        // Authentication & Profile
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IProfileService, ProfileService>();
        services.AddSingleton<ProfilePictureStorage>();

        // Email (D18): Resend when a key is set. Without one, only local runs may continue, with emails in the log.
        services.AddScoped<EmailCodeService>();
        if (!string.IsNullOrWhiteSpace(configuration["Email:ResendApiKey"]))
        {
            if (string.IsNullOrWhiteSpace(configuration["Email:From"]))
            {
                throw new InvalidOperationException("Email:From is missing.");
            }

            services.AddHttpClient<IEmailSender, ResendEmailSender>(client =>
            {
                client.BaseAddress = new Uri("https://api.resend.com/");
                client.Timeout = TimeSpan.FromSeconds(15);
            });
        }
        else if (environment.IsDevelopment() || environment.IsEnvironment("Testing"))
        {
            services.AddSingleton<IEmailSender, LogEmailSender>();
        }
        else
        {
            throw new InvalidOperationException("Email:ResendApiKey is missing.");
        }

        // Exercises
        services.AddScoped<IExerciseImportService, ExerciseImportService>();
        services.AddScoped<IExerciseService, ExerciseService>();
        services.AddSingleton<ExerciseCatalog>();
        services.TryAddSingleton(TimeProvider.System);

        // Workout Plans
        services.AddScoped<IWorkoutPlanService, WorkoutPlanService>();
        services.AddScoped<IWorkoutPlanExerciseService, WorkoutPlanExerciseService>();

        // Workout Sessions
        services.AddScoped<IWorkoutSessionService, WorkoutSessionService>();
        services.AddScoped<ISessionExerciseService, SessionExerciseService>();
        services.AddScoped<ICardioEntryService, CardioEntryService>();

        // Body Weight
        services.AddScoped<IBodyWeightService, BodyWeightService>();

        // Stats
        services.AddScoped<IStatsService, StatsService>();
        services.AddScoped<IVolumeService, VolumeService>();

        // External HTTP Client
        services.AddHttpClient("ExerciseDB", client =>
        {
            client.BaseAddress = new Uri("https://oss.exercisedb.dev/");
            client.Timeout = TimeSpan.FromSeconds(30);
        });

        return services;
    }
}
