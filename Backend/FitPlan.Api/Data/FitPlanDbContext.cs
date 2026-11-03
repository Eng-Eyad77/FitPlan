using FitPlan.Api.Data.Converters;
using FitPlan.Api.Models;
using Microsoft.EntityFrameworkCore;
namespace FitPlan.Api.Data;

public class FitPlanDbContext : DbContext
{
    public FitPlanDbContext(DbContextOptions<FitPlanDbContext> options)
        : base(options)
    {

    }

    public DbSet<User> Users => Set<User>();

    public DbSet<WorkoutPlan> WorkoutPlans => Set<WorkoutPlan>();

    public DbSet<Exercise> Exercises => Set<Exercise>();

    public DbSet<WorkoutPlanExercise> WorkoutPlanExercises => Set<WorkoutPlanExercise>();

    public DbSet<WorkoutSession> WorkoutSessions => Set<WorkoutSession>();

    public DbSet<SessionExercise> SessionExercises => Set<SessionExercise>();

    public DbSet<SessionSet> SessionSets => Set<SessionSet>();

    public DbSet<CardioEntry> CardioEntries => Set<CardioEntry>();

    public DbSet<BodyWeightEntry> BodyWeightEntries => Set<BodyWeightEntry>();


    // Applies to every DateTime property in every entity, including ones we add later.
    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        configurationBuilder.Properties<DateTime>()
            .HaveConversion<UtcDateTimeConverter>();

        configurationBuilder.Properties<DateTime?>()
            .HaveConversion<UtcDateTimeConverter>();
    }


    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ApplyConfigurationsFromAssembly(
            typeof(FitPlanDbContext).Assembly);
    }
}
