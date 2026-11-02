
using FitPlan.Api.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Register Services
builder.Services
    .AddDatabase(builder.Configuration)
    .AddAuthenticationServices(builder.Configuration)
    .AddApplicationServices()
    .AddSwaggerDocumentation();

builder.Services.AddControllers();

var app = builder.Build();

// Configure Application
app.ConfigureApplication();

app.Run();
