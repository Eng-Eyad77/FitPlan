
using System.Text.Json.Serialization;
using FitPlan.Api.Extensions;
using FitPlan.Api.Services.Exercises;

var builder = WebApplication.CreateBuilder(args);

// Register Services
builder.Services
    .AddErrorHandling()
    .AddDatabase(builder.Configuration, builder.Environment)
    .AddAuthenticationServices(builder.Configuration)
    .AddApplicationServices()
    .AddRateLimits()
    .AddSwaggerDocumentation()
    .AddCors();

// enums travel as text in the JSON ("Treadmill" instead of 1)
// exercise names in the request's language (Phase 11C), for every response that shows one
builder.Services.AddControllers(options => options.Filters.Add<ExerciseLanguageFilter>())
    .AddJsonOptions(options =>
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));

var app = builder.Build();

// Configure Application
app.ConfigureApplication();

app.Run();
