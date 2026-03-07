using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace GreenAIT.Data.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddGreenAITDatabase(this IServiceCollection services)
    {
        var host = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
        var port = Environment.GetEnvironmentVariable("DB_PORT") ?? "5432";
        var user = Environment.GetEnvironmentVariable("DB_USER") ?? "dev";
        var password = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "dev";
        var database = Environment.GetEnvironmentVariable("DB_NAME") ?? "greenai_dev";

        var connectionString = $"Host={host};Port={port};Database={database};Username={user};Password={password}";

        services.AddDbContext<GreenAITDbContext>(options =>
            options.UseNpgsql(connectionString));

        return services;
    }
}
