
using FitPlan.Api.Services.Auth;
using FitPlan.Api.Services.Profile;
using FitPlan.Api.Services.Exercises;
using FitPlan.Api.Services.WorkoutPlans;
using FitPlan.Api.Services.WorkoutPlanExercises;
using FitPlan.Api.Services.WorkoutSessions;
using FitPlan.Api.Services.SessionExercises;
using FitPlan.Api.Services.CardioEntries;
using FitPlan.Api.Services.BodyWeight;

namespace FitPlan.Api.Extensions;

public static class ServicesExtensions
{
    public static IServiceCollection AddApplicationServices(
        this IServiceCollection services)
    {
        // Authentication & Profile
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IProfileService, ProfileService>();

        // Exercises
        services.AddScoped<IExerciseImportService, ExerciseImportService>();
        services.AddScoped<IExerciseService, ExerciseService>();

        // Workout Plans
        services.AddScoped<IWorkoutPlanService, WorkoutPlanService>();
        services.AddScoped<IWorkoutPlanExerciseService, WorkoutPlanExerciseService>();

        // Workout Sessions
        services.AddScoped<IWorkoutSessionService, WorkoutSessionService>();
        services.AddScoped<ISessionExerciseService, SessionExerciseService>();
        services.AddScoped<ICardioEntryService, CardioEntryService>();

        // Body Weight
        services.AddScoped<IBodyWeightService, BodyWeightService>();

        // External HTTP Client
        services.AddHttpClient("ExerciseDB", client =>
        {
            client.BaseAddress = new Uri("https://oss.exercisedb.dev/");
            client.Timeout = TimeSpan.FromSeconds(30);
        });

        return services;
    }
}
