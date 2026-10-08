using System;
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
}
