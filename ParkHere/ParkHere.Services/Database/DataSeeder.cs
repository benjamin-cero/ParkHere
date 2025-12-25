using ParkHere.Services.Database;
using ParkHere.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;
using System.Drawing;
using System.Runtime.ConstrainedExecution;
using System.Collections.Generic;
using System.Linq;

namespace ParkHere.Services.Database
{
    public static class DataSeeder
    {
        private const string DefaultPhoneNumber = "+387 61 123 456";

        public static void SeedData(this ModelBuilder modelBuilder)
        {
            // Use a fixed date for all timestamps
            var fixedDate = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc);

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
            // Salt and hash will be generated per user based on username

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
                var username = $"user{startId + i}";
                var salt = PasswordGenerator.GenerateDeterministicSalt(username);
                var hash = PasswordGenerator.GenerateHash(defaultPassword, salt);

                users.Add(new User
                {
                    Id = startId + i,
                    FirstName = randomNames[i].Item1,
                    LastName = randomNames[i].Item2,
                    Email = $"{randomNames[i].Item1.ToLower()}.{randomNames[i].Item2.ToLower()}@example.com",
                    Username = username,
                    PasswordHash = hash,
                    PasswordSalt = salt,
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

            var parkingSpotTypes = new[]
            {
                new ParkingSpotType { Id = 1, Type = "Regular", PriceMultiplier = 1.00m, IsActive = true },
                new ParkingSpotType { Id = 2, Type = "VIP", PriceMultiplier = 1.50m, IsActive = true },
                new ParkingSpotType { Id = 3, Type = "Handicapped", PriceMultiplier = 0.75m, IsActive = true },
                new ParkingSpotType { Id = 4, Type = "Electric", PriceMultiplier = 1.20m, IsActive = true }
            };

            modelBuilder.Entity<ParkingSpotType>().HasData(parkingSpotTypes);

            var vehicles = new List<Vehicle>();
            int vehicleIdCounter = 1;

            foreach (var user in users)
            {
                // Default 1 vehicle per user
                int vehiclesCount = 1;
                
                // Benjamin (Id 2) gets 2 vehicles
                if (user.Id == 2)
                {
                    vehiclesCount = 2;
                }

                for (int i = 1; i <= vehiclesCount; i++)
                {
                    bool isActive = true;
                    // Special case for Benjamin (Id 2): 2nd vehicle is inactive
                    if (user.Id == 2 && i == 2)
                    {
                        isActive = false;
                    }

                    string licensePlate = $"VHC-{user.Id:D3}-{i}";

                    vehicles.Add(new Vehicle
                    {
                        Id = vehicleIdCounter++,
                        LicensePlate = licensePlate,
                        UserId = user.Id,
                        IsActive = isActive
                    });
                }
            }

            modelBuilder.Entity<Vehicle>().HasData(vehicles);


            var parkingSpots = new List<ParkingSpot>();
            int spotIdCounter = 1;
            int spotsPerWing = 15;

            // Wings 1-8 are defined above.
            // Wing 1 (Left), 2 (Right) -> Sector 1 (A1)
            // Wing 3 (Left), 4 (Right) -> Sector 2 (A2)
            // Wing 5 (Left), 6 (Right) -> Sector 3 (A3)
            // Wing 7 (Left), 8 (Right) -> Sector 4 (A4) - Inactive

            for (int wingId = 1; wingId <= 8; wingId++)
            {
                // Determine Sector and Wing Name for code generation
                // Wings 1,3,5,7 are Left. Wings 2,4,6,8 are Right.
                bool isLeft = (wingId % 2 != 0);
                string wingInitial = isLeft ? "L" : "R";
                
                // Sectors: 1->1, 2->1; 3->2, 4->2; etc.
                int sectorId = (wingId + 1) / 2;
                string sectorName = $"A{sectorId}"; // Or similar logic if names were dynamic

                // Sector 4 is inactive
                bool isSectorActive = (sectorId != 4);
                
                for (int i = 1; i <= spotsPerWing; i++)
                {
                    // Spot Code e.g. "A1-  L1", "A1-  L15"
                    string spotCode = $"{sectorName}-  {wingInitial}{i}";

                    // Distribute types somewhat randomly or cyclically
                    // 1=Regular, 2=VIP, 3=Handicapped, 4=Electric
                    int typeId = 1; 
                    if (sectorId == 2) typeId = 2; // VIP floor? Or mix
                    else if (i % 10 == 0) typeId = 3; // Every 10th handicapped
                    else if (i % 7 == 0) typeId = 4; // Every 7th electric
                    
                    parkingSpots.Add(new ParkingSpot
                    {
                        Id = spotIdCounter++,
                        SpotCode = spotCode,
                        ParkingWingId = wingId,
                        ParkingSpotTypeId = typeId,
                        IsOccupied = false,
                        IsActive = isSectorActive
                    });
                }
            }

            modelBuilder.Entity<ParkingSpot>().HasData(parkingSpots);



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

            // Seed ParkingReservations
            // Strategy: One reservation per user
            // Price calculation base on spot type multiplier
            
            var reservations = new List<ParkingReservation>();
            int reservationIdCounter = 1;
            decimal baseHourlyRate = 5.0m;

            for (int i = 0; i < users.Count; i++)
            {
                var user = users[i];
                // Find user's first vehicle
                var vehicle = vehicles.FirstOrDefault(v => v.UserId == user.Id && v.IsActive);
                
                // If user has no active vehicle, skip (shouldn't happen with current seed logic)
                if (vehicle == null) continue;

                // Assign a unique spot to each user sequentially
                // Check bounds just in case
                if (i >= parkingSpots.Count) break; 
                var spot = parkingSpots[i];

                // Calculate Price dynamically using the seeded ParkingSpotTypes
                var spotType = parkingSpotTypes.FirstOrDefault(pst => pst.Id == spot.ParkingSpotTypeId);
                decimal multiplier = spotType?.PriceMultiplier ?? 1.0m;

                // Create a reasonable time slot in the PAST
                // e.g., 5 days BEFORE fixedDate, staggered by hour
                DateTime start = fixedDate.AddDays(-5).AddHours(10 + i); 
                DateTime end = start.AddHours(2); // 2 hours duration

                decimal price = baseHourlyRate * 2 * multiplier; // 2 hours

                reservations.Add(new ParkingReservation
                {
                    Id = reservationIdCounter++,
                    UserId = user.Id,
                    VehicleId = vehicle.Id,
                    ParkingSpotId = spot.Id,
                    StartTime = start,
                    EndTime = end,
                    Price = Math.Round(price, 2),
                    IsPaid = true, // Seeed reservations are paid
                    CreatedAt = fixedDate.AddDays(-10) // Created even earlier
                });
            }

            modelBuilder.Entity<ParkingReservation>().HasData(reservations);


            // Seed ParkingSessions
            // Create sessions for complete reservations
            var sessions = new List<ParkingSession>();
            int sessionIdCounter = 1;

            foreach (var reservation in reservations)
            {
                // Determine if this user overstayed
                // e.g., every 3rd user overstays
                bool overstay = (reservation.Id % 3 == 0);

                DateTime actualStart = reservation.StartTime.AddMinutes(new Random(reservation.Id).Next(-5, 10)); // Arrived -5 to +10 mins
                DateTime actualEnd = reservation.EndTime;

                int extraMinutes = 0;
                decimal extraCharge = 0;

                if (overstay)
                {
                    // Overstay by 15-120 minutes
                    int overstayMinutes = new Random(reservation.Id).Next(15, 120);
                    actualEnd = actualEnd.AddMinutes(overstayMinutes);
                    
                    extraMinutes = (int)(actualEnd - reservation.EndTime).TotalMinutes;
                    
                    // Calculate extra charge
                    // Use same multiplier as reservation
                    // Assumption: Penalty rate is same as hourly rate
                    // Price per minute = (baseHourlyRate * multiplier) / 60
                    
                    // We need the multiplier again. 
                    // Optimization: We could store it, but acceptable to lookup or re-calculate for seed
                    // Look up spot type from spot id... which is in reservation...
                    // But reservation.ParkingSpot is not populated in this list context, only IDs.
                    // So we find the spot from the spot list.
                    
                    var spot = parkingSpots.FirstOrDefault(s => s.Id == reservation.ParkingSpotId);
                    var spotType = parkingSpotTypes.FirstOrDefault(pst => pst.Id == spot?.ParkingSpotTypeId);
                    decimal multiplier = spotType?.PriceMultiplier ?? 1.0m;

                    decimal pricePerMinute = (baseHourlyRate * multiplier) / 60.0m;
                    extraCharge = pricePerMinute * extraMinutes;
                }
                else
                {
                   // Left 0-10 mins early or on time
                   actualEnd = actualEnd.AddMinutes(-new Random(reservation.Id).Next(0, 10));
                }

                sessions.Add(new ParkingSession
                {
                    Id = sessionIdCounter++,
                    ParkingReservationId = reservation.Id,
                    ActualStartTime = actualStart,
                    ActualEndTime = actualEnd,
                    ExtraMinutes = extraMinutes,
                    ExtraCharge = Math.Round(extraCharge, 2),
                    CreatedAt = actualStart // created when session started
                });
            }

            modelBuilder.Entity<ParkingSession>().HasData(sessions);
        }
    }
}