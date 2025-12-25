using Microsoft.EntityFrameworkCore;

namespace ParkHere.Services.Database
{
    public class ParkHereDbContext : DbContext
    {
        public ParkHereDbContext(DbContextOptions<ParkHereDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Gender> Genders { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<ParkingSpotType> ParkingSpotTypes { get; set; }
        public DbSet<ParkingSector> ParkingSectors { get; set; }
        public DbSet<ParkingWing> ParkingWings { get; set; }
        public DbSet<ParkingSpot> ParkingSpots { get; set; }
        public DbSet<Vehicle> Vehicles { get; set; }
        public DbSet<ParkingReservation> ParkingReservations { get; set; }
        public DbSet<ParkingSession> ParkingSessions { get; set; }
    

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User entity
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();
               

            // Configure Role entity
            modelBuilder.Entity<Role>()
                .HasIndex(r => r.Name)
                .IsUnique();

            // Configure UserRole join entity
            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            // Create a unique constraint on UserId and RoleId
            modelBuilder.Entity<UserRole>()
                .HasIndex(ur => new { ur.UserId, ur.RoleId })
                .IsUnique();

         

            // Configure Gender entity
            modelBuilder.Entity<Gender>()
                .HasIndex(g => g.Name)
                .IsUnique();

            // Configure City entity
            modelBuilder.Entity<City>()
                .HasIndex(c => c.Name)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasOne(u => u.Gender)
                .WithMany()
                .HasForeignKey(u => u.GenderId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<User>()
                .HasOne(u => u.City)
                .WithMany()
                .HasForeignKey(u => u.CityId)
                .OnDelete(DeleteBehavior.NoAction);



            // ParkingReservation -> User, Vehicle, ParkingSpot
            modelBuilder.Entity<ParkingReservation>()
                .HasOne(pr => pr.User)
                .WithMany() // mo�e� kasnije dodati ICollection<ParkingReservation> u User
                .HasForeignKey(pr => pr.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<ParkingReservation>()
                .HasOne(pr => pr.Vehicle)
                .WithMany() // isto ovdje
                .HasForeignKey(pr => pr.VehicleId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<ParkingReservation>()
                .HasOne(pr => pr.ParkingSpot)
                .WithMany() // isto ovdje
                .HasForeignKey(pr => pr.ParkingSpotId)
                .OnDelete(DeleteBehavior.Restrict);

            // ParkingSession -> ParkingReservation
            modelBuilder.Entity<ParkingSession>()
                .HasOne(ps => ps.ParkingReservation)
                .WithMany() // ili dodaj ICollection<ParkingSession> u ParkingReservation
                .HasForeignKey(ps => ps.ParkingReservationId)
                .OnDelete(DeleteBehavior.Cascade);






            // Seed initial data
            modelBuilder.SeedData();
        }
    }
} 