using FitPlan.Api.Data;
using FitPlan.Api.Services.Auth;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using FitPlan.Api.Services.Profile;
using Microsoft.EntityFrameworkCore.Storage;
using FitPlan.Api.Services.Exercises;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
.AddJwtBearer(option =>
{
    option.TokenValidationParameters = new TokenValidationParameters
    {
         ValidateIssuer = true,
         ValidIssuer = builder.Configuration["Jwt:Issuer"],
         ValidateAudience = true,
         ValidAudience = builder.Configuration["Jwt:Audience"],
         ValidateLifetime = true,
         IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!)
         ),
        ValidateIssuerSigningKey = true

    };
} );

builder.Services.AddControllers();


builder.Services.AddDbContext<FitPlanDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("FitPlanDb")));
// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();



builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IProfileService, ProfileService>();
builder.Services.AddScoped<IExerciseImportService, ExerciseImportService>();


builder.Services.AddHttpClient("ExerciseDB", client =>
{
    client.BaseAddress = new Uri("https://oss.exercisedb.dev/");
    client.Timeout = TimeSpan.FromSeconds(30);
});


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();


app.UseAuthentication();
app.UseAuthorization();

app.UseStaticFiles();
app.MapControllers();

app.Run();

