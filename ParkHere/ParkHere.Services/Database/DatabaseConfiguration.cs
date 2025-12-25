using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace ParkHere.Services.Database
{
    public static class DatabaseConfiguration
    {
        public static void AddDatabaseServices(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<ParkHereDbContext>(options =>
                options.UseSqlServer(connectionString));
        }

        public static void AddDatabaseParkHere(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<ParkHereDbContext>(options =>
                options.UseSqlServer(connectionString));
        }
    }
}