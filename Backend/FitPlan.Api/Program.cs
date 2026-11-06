
using System.Text.Json.Serialization;
using FitPlan.Api.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Register Services
builder.Services
    .AddErrorHandling()
    .AddDatabase(builder.Configuration, builder.Environment)
    .AddAuthenticationServices(builder.Configuration)
    .AddApplicationServices()
    .AddSwaggerDocumentation()
    .AddCors();

// enums travel as text in the JSON ("Treadmill" instead of 1)
builder.Services.AddControllers()
    .AddJsonOptions(options =>
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));

var app = builder.Build();

// Configure Application
app.ConfigureApplication();

app.Run();
