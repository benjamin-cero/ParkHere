using ParkHere.Services.Database;
using ParkHere.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;
using System.Drawing;
using System.Runtime.ConstrainedExecution;
using System.Collections.Generic;

namespace ParkHere.Services.Database
{
    public static class DataSeeder
    {
        private const string DefaultPhoneNumber = "+387 61 123 456";

        public static void SeedData(this ModelBuilder modelBuilder)
        {
            // Use a fixed date for all timestamps
            var fixedDate = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);

            // Seed Roles
            modelBuilder.Entity<Role>().HasData(
                   new Role
                   {
                       Id = 1,
                       Name = "Administrator",
                       Description = "Full system access and administrative privileges",
                       CreatedAt = fixedDate,
                       IsActive = true
                   },
                   new Role
                   {
                       Id = 2,
                       Name = "User",
                       Description = "Standard user with limited system access",
                       CreatedAt = fixedDate,
                       IsActive = true
                   }
            );


            const string defaultPassword = "test";

            // Password for Adil (Admin)
            var desktopSalt = PasswordGenerator.GenerateDeterministicSalt("desktop");
            var desktopHash = PasswordGenerator.GenerateHash(defaultPassword, desktopSalt);

            // Password for Benjamin (User 2)
            var userSalt = PasswordGenerator.GenerateDeterministicSalt("user");
            var userHash = PasswordGenerator.GenerateHash(defaultPassword, userSalt);

            // Password for Elmir (Admin 2)
            var admin2Salt = PasswordGenerator.GenerateDeterministicSalt("admin2");
            var admin2Hash = PasswordGenerator.GenerateHash(defaultPassword, admin2Salt);

            // Common password for generated users
            var commonUserSalt = PasswordGenerator.GenerateDeterministicSalt("common");
            var commonUserHash = PasswordGenerator.GenerateHash(defaultPassword, commonUserSalt);

            var users = new List<User>
            {
                // Admin 1
                new User
                {
                    Id = 1,
                    FirstName = "Adil",
                    LastName = "Joldic",
                    Email = "adil.joldic@parkhere.com",
                    Username = "desktop",
                    PasswordHash = desktopHash,
                    PasswordSalt = desktopSalt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 1 // Sarajevo
                },
                // User 2 (Benjamin Cero) - Preserved username/email
                new User
                {
                    Id = 2,
                    FirstName = "Benjamin",
                    LastName = "Cero",
                    Email = "parkhere.receive@gmail.com",
                    Username = "user",
                    PasswordHash = userHash,
                    PasswordSalt = userSalt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5 // Mostar
                },
                // Admin 2 (Elmir Babovic)
                new User
                {
                    Id = 3,
                    FirstName = "Elmir",
                    LastName = "Babovic",
                    Email = "elmir.babovic@parkhere.com",
                    Username = "admin2",
                    PasswordHash = admin2Hash,
                    PasswordSalt = admin2Salt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 3 // Tuzla
                }
            };

            // Generate 9 random users
            var randomNames = new[]
            {
                ("Haris", "Horozovic"), ("Faris", "Festic"), ("Adna", "Adnic"),
                ("Edin", "Edinic"), ("Maja", "Majic"), ("Sara", "Saric"),
                ("Ivan", "Ivic"), ("Luka", "Lukic"), ("Ana", "Anic")
            };

            int startId = 4;
            for (int i = 0; i < randomNames.Length; i++)
            {
                users.Add(new User
                {
                    Id = startId + i,
                    FirstName = randomNames[i].Item1,
                    LastName = randomNames[i].Item2,
                    Email = $"{randomNames[i].Item1.ToLower()}.{randomNames[i].Item2.ToLower()}@example.com",
                    Username = $"user{startId + i}",
                    PasswordHash = commonUserHash,
                    PasswordSalt = commonUserSalt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = (i % 2 == 0) ? 1 : 2, // Alternating gender roughly
                    CityId = (i % 10) + 1 // Cycle through cities
                });
            }

            modelBuilder.Entity<User>().HasData(users);

            // Seed UserRoles
            var userRoles = new List<UserRole>();
            
            // Assign roles
            foreach (var user in users)
            {
                // ID 1 and 3 are Admins, rest are Users
                int roleId = (user.Id == 1 || user.Id == 3) ? 1 : 2;
                
                userRoles.Add(new UserRole
                {
                    Id = user.Id, // Use same ID for UserRole as User for simplicity
                    UserId = user.Id,
                    RoleId = roleId,
                    DateAssigned = fixedDate
                });
            }

            modelBuilder.Entity<UserRole>().HasData(userRoles);


            modelBuilder.Entity<ParkingSector>().HasData(
                new ParkingSector { Id = 1, FloorNumber = 0, Name = "A1", IsActive = true },
                new ParkingSector { Id = 2, FloorNumber = 1, Name = "A2", IsActive = true },
                new ParkingSector { Id = 3, FloorNumber = 2, Name = "A3", IsActive = true },
                new ParkingSector { Id = 4, FloorNumber = 3, Name = "A4", IsActive = false }
            );

            modelBuilder.Entity<ParkingWing>().HasData(
                new ParkingWing { Id = 1, Name = "Left", ParkingSectorId = 1, IsActive = true },
                new ParkingWing { Id = 2, Name = "Right", ParkingSectorId = 1, IsActive = true },
                new ParkingWing { Id = 3, Name = "Left", ParkingSectorId = 2, IsActive = true },
                new ParkingWing { Id = 4, Name = "Right", ParkingSectorId = 2, IsActive = true },
                new ParkingWing { Id = 5, Name = "Left", ParkingSectorId = 3, IsActive = true },
                new ParkingWing { Id = 6, Name = "Right", ParkingSectorId = 3, IsActive = true },
                new ParkingWing { Id = 7, Name = "Left", ParkingSectorId = 4, IsActive = false },
                new ParkingWing { Id = 8, Name = "Right", ParkingSectorId = 4, IsActive = false }
            );

            modelBuilder.Entity<ParkingSpotType>().HasData(
                new ParkingSpotType { Id = 1, Type = "Regular", PriceMultiplier = 1.00m, IsActive = true },
                new ParkingSpotType { Id = 2, Type = "VIP", PriceMultiplier = 1.50m, IsActive = true },
                new ParkingSpotType { Id = 3, Type = "Handicapped", PriceMultiplier = 0.75m, IsActive = true },
                new ParkingSpotType { Id = 4, Type = "Electric", PriceMultiplier = 1.20m, IsActive = true }
            );

            modelBuilder.Entity<Vehicle>().HasData(
                new Vehicle { Id = 1, LicensePlate = "ABC-123", UserId = 1, IsActive = true },
                new Vehicle { Id = 2, LicensePlate = "DEF-456", UserId = 2, IsActive = true },
                new Vehicle { Id = 3, LicensePlate = "GHI-789", UserId = 3, IsActive = true },
                new Vehicle { Id = 4, LicensePlate = "JKL-012", UserId = 4, IsActive = true }
            );


            modelBuilder.Entity<ParkingSpot>().HasData(
                new ParkingSpot { Id = 1, SpotCode = "A1-  L1",        ParkingWingId  = 1,  ParkingSpotTypeId  = 1,      IsOccupied  =   false,   IsActive =   true },
                new ParkingSpot { Id = 2, SpotCode = "A1-  R1",        ParkingWingId  = 2,  ParkingSpotTypeId  = 1,      IsOccupied  =   false,   IsActive =   true },
                new ParkingSpot { Id = 3, SpotCode = "A2-  L1",        ParkingWingId  = 3,  ParkingSpotTypeId  = 2,      IsOccupied  =   false,   IsActive =   true },
                new ParkingSpot { Id = 4, SpotCode = "A2-  R1",        ParkingWingId  = 4,  ParkingSpotTypeId  = 2,      IsOccupied  =   false,   IsActive =   true },
                new ParkingSpot { Id = 5, SpotCode = "A3-  L1",        ParkingWingId  = 5,  ParkingSpotTypeId  = 3,      IsOccupied  =   false,   IsActive =   true },
                new ParkingSpot { Id = 6, SpotCode = "A3-  R1",        ParkingWingId  = 6,  ParkingSpotTypeId  = 3,      IsOccupied  =   false,   IsActive =   true },
                new ParkingSpot { Id = 7, SpotCode = "A4-  L1",        ParkingWingId  = 7,  ParkingSpotTypeId  = 1,      IsOccupied  =   false,   IsActive =   false }, 
                new ParkingSpot { Id = 8, SpotCode = "A4-  R1",        ParkingWingId  = 8,  ParkingSpotTypeId  = 1,      IsOccupied  =   false,   IsActive =   false } 
            );


            // Seed Genders
            modelBuilder.Entity<Gender>().HasData(
                new Gender { Id = 1, Name = "Male" },
                new Gender { Id = 2, Name = "Female" }
            );

            // Seed Cities
            modelBuilder.Entity<City>().HasData(
                new City { Id = 1, Name = "Sarajevo" },
                new City { Id = 2, Name = "Banja Luka" },
                new City { Id = 3, Name = "Tuzla" },
                new City { Id = 4, Name = "Zenica" },
                new City { Id = 5, Name = "Mostar" },
                new City { Id = 6, Name = "Bijeljina" },
                new City { Id = 7, Name = "Prijedor" },
                new City { Id = 8, Name = "Brčko" },
                new City { Id = 9, Name = "Doboj" },
                new City { Id = 10, Name = "Zvornik" }
            );

        }
    }
}