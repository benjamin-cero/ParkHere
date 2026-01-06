using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace ParkHere.Services.Migrations
{
    /// <inheritdoc />
    public partial class INIT : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Cities",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cities", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Genders",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Genders", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ParkingSectors",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FloorNumber = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ParkingSectors", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ParkingSpotTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Type = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    PriceMultiplier = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ParkingSpotTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Picture = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Username = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PasswordSalt = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    LastLoginAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    GenderId = table.Column<int>(type: "int", nullable: false),
                    CityId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Users_Cities_CityId",
                        column: x => x.CityId,
                        principalTable: "Cities",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Users_Genders_GenderId",
                        column: x => x.GenderId,
                        principalTable: "Genders",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ParkingWings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ParkingSectorId = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ParkingWings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ParkingWings_ParkingSectors_ParkingSectorId",
                        column: x => x.ParkingSectorId,
                        principalTable: "ParkingSectors",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserRoles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: false),
                    DateAssigned = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRoles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserRoles_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserRoles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Vehicles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    LicensePlate = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Vehicles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Vehicles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ParkingSpots",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SpotCode = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    ParkingWingId = table.Column<int>(type: "int", nullable: false),
                    ParkingSpotTypeId = table.Column<int>(type: "int", nullable: false),
                    IsOccupied = table.Column<bool>(type: "bit", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ParkingSpots", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ParkingSpots_ParkingSpotTypes_ParkingSpotTypeId",
                        column: x => x.ParkingSpotTypeId,
                        principalTable: "ParkingSpotTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ParkingSpots_ParkingWings_ParkingWingId",
                        column: x => x.ParkingWingId,
                        principalTable: "ParkingWings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ParkingReservations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    VehicleId = table.Column<int>(type: "int", nullable: false),
                    ParkingSpotId = table.Column<int>(type: "int", nullable: false),
                    StartTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    IncludedDebt = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    IsPaid = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ParkingReservations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ParkingReservations_ParkingSpots_ParkingSpotId",
                        column: x => x.ParkingSpotId,
                        principalTable: "ParkingSpots",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ParkingReservations_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ParkingReservations_Vehicles_VehicleId",
                        column: x => x.VehicleId,
                        principalTable: "Vehicles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ParkingSessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ParkingReservationId = table.Column<int>(type: "int", nullable: false),
                    ActualStartTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ArrivalTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ActualEndTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ExtraMinutes = table.Column<int>(type: "int", nullable: true),
                    ExtraCharge = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ParkingSessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ParkingSessions_ParkingReservations_ParkingReservationId",
                        column: x => x.ParkingReservationId,
                        principalTable: "ParkingReservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ReservationId = table.Column<int>(type: "int", nullable: false),
                    Rating = table.Column<int>(type: "int", nullable: false),
                    Comment = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reviews", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reviews_ParkingReservations_ReservationId",
                        column: x => x.ReservationId,
                        principalTable: "ParkingReservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Reviews_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.InsertData(
                table: "Cities",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Sarajevo" },
                    { 2, "Banja Luka" },
                    { 3, "Tuzla" },
                    { 4, "Zenica" },
                    { 5, "Mostar" },
                    { 6, "Bijeljina" },
                    { 7, "Prijedor" },
                    { 8, "Brčko" },
                    { 9, "Doboj" },
                    { 10, "Zvornik" }
                });

            migrationBuilder.InsertData(
                table: "Genders",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Male" },
                    { 2, "Female" }
                });

            migrationBuilder.InsertData(
                table: "ParkingSectors",
                columns: new[] { "Id", "FloorNumber", "IsActive", "Name" },
                values: new object[,]
                {
                    { 1, 0, true, "A1" },
                    { 2, 1, true, "A2" },
                    { 3, 2, true, "A3" },
                    { 4, 3, false, "A4" }
                });

            migrationBuilder.InsertData(
                table: "ParkingSpotTypes",
                columns: new[] { "Id", "IsActive", "PriceMultiplier", "Type" },
                values: new object[,]
                {
                    { 1, true, 1.00m, "Regular" },
                    { 2, true, 1.50m, "VIP" },
                    { 3, true, 0.75m, "Handicapped" },
                    { 4, true, 1.20m, "Electric" }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Full system access and administrative privileges", true, "Administrator" },
                    { 2, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Standard user with limited system access", true, "User" }
                });

            migrationBuilder.InsertData(
                table: "ParkingWings",
                columns: new[] { "Id", "IsActive", "Name", "ParkingSectorId" },
                values: new object[,]
                {
                    { 1, true, "Left", 1 },
                    { 2, true, "Right", 1 },
                    { 3, true, "Left", 2 },
                    { 4, true, "Right", 2 },
                    { 5, true, "Left", 3 },
                    { 6, true, "Right", 3 },
                    { 7, false, "Left", 4 },
                    { 8, false, "Right", 4 }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CityId", "CreatedAt", "Email", "FirstName", "GenderId", "IsActive", "LastLoginAt", "LastName", "PasswordHash", "PasswordSalt", "PhoneNumber", "Picture", "Username" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "adil.joldic@parkhere.com", "Adil", 1, true, null, "Joldic", "SKCEf8PFXFpwXefUyKkpl6MMBen54WiyctXTCdWrHd0=", "aGk9AqtPuyMxuMw5kVMi5A==", "+387 61 123 456", null, "desktop" },
                    { 2, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "parkhere.receive@gmail.com", "Benjamin", 1, true, null, "Cero", "+/pM4+5rgrwaezXoDcdKMtyc2Q7IM+rGT5qT8AOUBRE=", "BPiZbadjt6lpsQKO4wB1aQ==", "+387 61 123 456", null, "user" },
                    { 3, 3, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "elmir.babovic@parkhere.com", "Elmir", 1, true, null, "Babovic", "vlAx8k6vnwwlvR7VmvHyN82cIDhXROKGCAoEKA7BwFI=", "HBQrLQGqNOmja95IBkWlfw==", "+387 61 123 456", null, "admin2" },
                    { 4, 1, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "haris.horozovic@example.com", "Haris", 1, true, null, "Horozovic", "mtFJH04D349xXkUMfA4tp+BOjxlZcjm6uv7HP00C3yc=", "UmnvmA3keBm6PRQ0D0ZlJg==", "+387 61 123 456", null, "user4" },
                    { 5, 2, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "faris.festic@example.com", "Faris", 2, true, null, "Festic", "dlD2S1dpzmbVudRYt/XjL99kbQxtHMSKkGGdAMNY9Hg=", "Wjm+rTGPMGk5rLHQFmR74g==", "+387 61 123 456", null, "user5" },
                    { 6, 3, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "adna.adnic@example.com", "Adna", 1, true, null, "Adnic", "dcJhdhYypJ7d0fEaMehy5nP2f3lxypSzm9psBLmfsO8=", "7LSKHMlPlRJS7EYv6ezFXA==", "+387 61 123 456", null, "user6" },
                    { 7, 4, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "edin.edinic@example.com", "Edin", 2, true, null, "Edinic", "DRKrAdQZxSIqX5yevQK5mgryL9t0dFyZLKRXrX2/9g0=", "MmgVHlLZe0ys+X9bRqXHbA==", "+387 61 123 456", null, "user7" },
                    { 8, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "maja.majic@example.com", "Maja", 1, true, null, "Majic", "JDpi7VMo8vu+/VjoBvwmiDnLXtqNCdnXuvzz6E7wo2g=", "9gr6SYmn2xMxSiq5iBNyYw==", "+387 61 123 456", null, "user8" },
                    { 9, 6, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "sara.saric@example.com", "Sara", 2, true, null, "Saric", "Kc0E1mK6NnBfOKag43jNd4+UVx65Q4ml4JRF5fpt2TY=", "D7jTxd+vgaOHvwukOatA5g==", "+387 61 123 456", null, "user9" },
                    { 10, 7, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "ivan.ivic@example.com", "Ivan", 1, true, null, "Ivic", "NXjAoMRrSyEXvRIoeAAP7fgcfj0UNqhSW4GCyis2otU=", "W78ang3gYiJaG7ffjYs3GQ==", "+387 61 123 456", null, "user10" },
                    { 11, 8, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "luka.lukic@example.com", "Luka", 2, true, null, "Lukic", "hUoGV+UffxvXNFKrJuGf2G6D3peZxypzpFHPM1vrl1c=", "gRFeMeIqWAGxl3UOwS16UQ==", "+387 61 123 456", null, "user11" },
                    { 12, 9, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "ana.anic@example.com", "Ana", 1, true, null, "Anic", "cdc68KpPVpZFVq38/q1XXQCe7pqKgtw5hjSmJf+BKQg=", "vTUoP+j8/XfXwFqL8q24XA==", "+387 61 123 456", null, "user12" }
                });

            migrationBuilder.InsertData(
                table: "ParkingSpots",
                columns: new[] { "Id", "IsActive", "IsOccupied", "ParkingSpotTypeId", "ParkingWingId", "SpotCode" },
                values: new object[,]
                {
                    { 1, true, false, 1, 1, "A1-  L1" },
                    { 2, true, false, 1, 1, "A1-  L2" },
                    { 3, true, false, 1, 1, "A1-  L3" },
                    { 4, true, false, 1, 1, "A1-  L4" },
                    { 5, true, false, 1, 1, "A1-  L5" },
                    { 6, true, false, 1, 1, "A1-  L6" },
                    { 7, true, false, 4, 1, "A1-  L7" },
                    { 8, true, false, 1, 1, "A1-  L8" },
                    { 9, true, false, 1, 1, "A1-  L9" },
                    { 10, true, false, 3, 1, "A1-  L10" },
                    { 11, true, false, 1, 1, "A1-  L11" },
                    { 12, true, false, 1, 1, "A1-  L12" },
                    { 13, true, false, 1, 1, "A1-  L13" },
                    { 14, true, false, 4, 1, "A1-  L14" },
                    { 15, true, false, 1, 1, "A1-  L15" },
                    { 16, true, false, 1, 2, "A1-  R1" },
                    { 17, true, false, 1, 2, "A1-  R2" },
                    { 18, true, false, 1, 2, "A1-  R3" },
                    { 19, true, false, 1, 2, "A1-  R4" },
                    { 20, true, false, 1, 2, "A1-  R5" },
                    { 21, true, false, 1, 2, "A1-  R6" },
                    { 22, true, false, 4, 2, "A1-  R7" },
                    { 23, true, false, 1, 2, "A1-  R8" },
                    { 24, true, false, 1, 2, "A1-  R9" },
                    { 25, true, false, 3, 2, "A1-  R10" },
                    { 26, true, false, 1, 2, "A1-  R11" },
                    { 27, true, false, 1, 2, "A1-  R12" },
                    { 28, true, false, 1, 2, "A1-  R13" },
                    { 29, true, false, 4, 2, "A1-  R14" },
                    { 30, true, false, 1, 2, "A1-  R15" },
                    { 31, true, false, 2, 3, "A2-  L1" },
                    { 32, true, false, 2, 3, "A2-  L2" },
                    { 33, true, false, 2, 3, "A2-  L3" },
                    { 34, true, false, 2, 3, "A2-  L4" },
                    { 35, true, false, 2, 3, "A2-  L5" },
                    { 36, true, false, 2, 3, "A2-  L6" },
                    { 37, true, false, 2, 3, "A2-  L7" },
                    { 38, true, false, 2, 3, "A2-  L8" },
                    { 39, true, false, 2, 3, "A2-  L9" },
                    { 40, true, false, 2, 3, "A2-  L10" },
                    { 41, true, false, 2, 3, "A2-  L11" },
                    { 42, true, false, 2, 3, "A2-  L12" },
                    { 43, true, false, 2, 3, "A2-  L13" },
                    { 44, true, false, 2, 3, "A2-  L14" },
                    { 45, true, false, 2, 3, "A2-  L15" },
                    { 46, true, false, 2, 4, "A2-  R1" },
                    { 47, true, false, 2, 4, "A2-  R2" },
                    { 48, true, false, 2, 4, "A2-  R3" },
                    { 49, true, false, 2, 4, "A2-  R4" },
                    { 50, true, false, 2, 4, "A2-  R5" },
                    { 51, true, false, 2, 4, "A2-  R6" },
                    { 52, true, false, 2, 4, "A2-  R7" },
                    { 53, true, false, 2, 4, "A2-  R8" },
                    { 54, true, false, 2, 4, "A2-  R9" },
                    { 55, true, false, 2, 4, "A2-  R10" },
                    { 56, true, false, 2, 4, "A2-  R11" },
                    { 57, true, false, 2, 4, "A2-  R12" },
                    { 58, true, false, 2, 4, "A2-  R13" },
                    { 59, true, false, 2, 4, "A2-  R14" },
                    { 60, true, false, 2, 4, "A2-  R15" },
                    { 61, true, false, 1, 5, "A3-  L1" },
                    { 62, true, false, 1, 5, "A3-  L2" },
                    { 63, true, false, 1, 5, "A3-  L3" },
                    { 64, true, false, 1, 5, "A3-  L4" },
                    { 65, true, false, 1, 5, "A3-  L5" },
                    { 66, true, false, 1, 5, "A3-  L6" },
                    { 67, true, false, 4, 5, "A3-  L7" },
                    { 68, true, false, 1, 5, "A3-  L8" },
                    { 69, true, false, 1, 5, "A3-  L9" },
                    { 70, true, false, 3, 5, "A3-  L10" },
                    { 71, true, false, 1, 5, "A3-  L11" },
                    { 72, true, false, 1, 5, "A3-  L12" },
                    { 73, true, false, 1, 5, "A3-  L13" },
                    { 74, true, false, 4, 5, "A3-  L14" },
                    { 75, true, false, 1, 5, "A3-  L15" },
                    { 76, true, false, 1, 6, "A3-  R1" },
                    { 77, true, false, 1, 6, "A3-  R2" },
                    { 78, true, false, 1, 6, "A3-  R3" },
                    { 79, true, false, 1, 6, "A3-  R4" },
                    { 80, true, false, 1, 6, "A3-  R5" },
                    { 81, true, false, 1, 6, "A3-  R6" },
                    { 82, true, false, 4, 6, "A3-  R7" },
                    { 83, true, false, 1, 6, "A3-  R8" },
                    { 84, true, false, 1, 6, "A3-  R9" },
                    { 85, true, false, 3, 6, "A3-  R10" },
                    { 86, true, false, 1, 6, "A3-  R11" },
                    { 87, true, false, 1, 6, "A3-  R12" },
                    { 88, true, false, 1, 6, "A3-  R13" },
                    { 89, true, false, 4, 6, "A3-  R14" },
                    { 90, true, false, 1, 6, "A3-  R15" },
                    { 91, false, false, 1, 7, "A4-  L1" },
                    { 92, false, false, 1, 7, "A4-  L2" },
                    { 93, false, false, 1, 7, "A4-  L3" },
                    { 94, false, false, 1, 7, "A4-  L4" },
                    { 95, false, false, 1, 7, "A4-  L5" },
                    { 96, false, false, 1, 7, "A4-  L6" },
                    { 97, false, false, 4, 7, "A4-  L7" },
                    { 98, false, false, 1, 7, "A4-  L8" },
                    { 99, false, false, 1, 7, "A4-  L9" },
                    { 100, false, false, 3, 7, "A4-  L10" },
                    { 101, false, false, 1, 7, "A4-  L11" },
                    { 102, false, false, 1, 7, "A4-  L12" },
                    { 103, false, false, 1, 7, "A4-  L13" },
                    { 104, false, false, 4, 7, "A4-  L14" },
                    { 105, false, false, 1, 7, "A4-  L15" },
                    { 106, false, false, 1, 8, "A4-  R1" },
                    { 107, false, false, 1, 8, "A4-  R2" },
                    { 108, false, false, 1, 8, "A4-  R3" },
                    { 109, false, false, 1, 8, "A4-  R4" },
                    { 110, false, false, 1, 8, "A4-  R5" },
                    { 111, false, false, 1, 8, "A4-  R6" },
                    { 112, false, false, 4, 8, "A4-  R7" },
                    { 113, false, false, 1, 8, "A4-  R8" },
                    { 114, false, false, 1, 8, "A4-  R9" },
                    { 115, false, false, 3, 8, "A4-  R10" },
                    { 116, false, false, 1, 8, "A4-  R11" },
                    { 117, false, false, 1, 8, "A4-  R12" },
                    { 118, false, false, 1, 8, "A4-  R13" },
                    { 119, false, false, 4, 8, "A4-  R14" },
                    { 120, false, false, 1, 8, "A4-  R15" }
                });

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "Id", "DateAssigned", "RoleId", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 2, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 3, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, 3 },
                    { 4, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 4 },
                    { 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 5 },
                    { 6, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 6 },
                    { 7, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 7 },
                    { 8, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 8 },
                    { 9, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 9 },
                    { 10, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 10 },
                    { 11, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 11 },
                    { 12, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 12 }
                });

            migrationBuilder.InsertData(
                table: "Vehicles",
                columns: new[] { "Id", "IsActive", "LicensePlate", "Name", "UserId" },
                values: new object[,]
                {
                    { 1, true, "VHC-001-1", "Primary Vehicle", 1 },
                    { 2, true, "VHC-002-1", "Benjamin's SUV", 2 },
                    { 3, false, "VHC-002-2", "Old Sedan", 2 },
                    { 4, true, "VHC-003-1", "Primary Vehicle", 3 },
                    { 5, true, "VHC-004-1", "Primary Vehicle", 4 },
                    { 6, true, "VHC-005-1", "Primary Vehicle", 5 },
                    { 7, true, "VHC-006-1", "Primary Vehicle", 6 },
                    { 8, true, "VHC-007-1", "Primary Vehicle", 7 },
                    { 9, true, "VHC-008-1", "Primary Vehicle", 8 },
                    { 10, true, "VHC-009-1", "Primary Vehicle", 9 },
                    { 11, true, "VHC-010-1", "Primary Vehicle", 10 },
                    { 12, true, "VHC-011-1", "Primary Vehicle", 11 },
                    { 13, true, "VHC-012-1", "Primary Vehicle", 12 }
                });

            migrationBuilder.InsertData(
                table: "ParkingReservations",
                columns: new[] { "Id", "CreatedAt", "EndTime", "IncludedDebt", "IsPaid", "ParkingSpotId", "Price", "StartTime", "UserId", "VehicleId" },
                values: new object[,]
                {
                    { 1, new DateTime(2024, 12, 31, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 3, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 30, 9.00m, new DateTime(2025, 1, 3, 13, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 2, new DateTime(2025, 1, 10, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 11, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 93, 9.00m, new DateTime(2025, 1, 11, 9, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 3, new DateTime(2025, 1, 16, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 19, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 36, 4.50m, new DateTime(2025, 1, 19, 18, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 4, new DateTime(2025, 1, 26, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 27, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 98, 6.00m, new DateTime(2025, 1, 27, 14, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 5, new DateTime(2025, 1, 6, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 8, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 41, 9.00m, new DateTime(2025, 1, 8, 11, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 6, new DateTime(2025, 1, 12, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 16, 22, 0, 0, 0, DateTimeKind.Utc), null, true, 104, 10.80m, new DateTime(2025, 1, 16, 19, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 7, new DateTime(2025, 1, 22, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 24, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 46, 4.50m, new DateTime(2025, 1, 24, 15, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 8, new DateTime(2025, 1, 1, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 5, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 109, 3.00m, new DateTime(2025, 1, 5, 12, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 9, new DateTime(2025, 1, 11, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 13, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 52, 9.00m, new DateTime(2025, 1, 13, 8, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 10, new DateTime(2025, 1, 18, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 21, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 115, 6.75m, new DateTime(2025, 1, 21, 17, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 11, new DateTime(2025, 1, 1, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 2, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 57, 13.50m, new DateTime(2025, 1, 2, 13, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 12, new DateTime(2025, 1, 7, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 10, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 120, 3.00m, new DateTime(2025, 1, 10, 9, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 13, new DateTime(2025, 1, 17, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 18, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 63, 3.00m, new DateTime(2025, 1, 18, 18, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 14, new DateTime(2025, 1, 22, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 25, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 5, 6.00m, new DateTime(2025, 1, 25, 14, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 15, new DateTime(2025, 2, 2, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 6, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 68, 9.00m, new DateTime(2025, 2, 6, 11, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 16, new DateTime(2025, 2, 12, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 14, 22, 0, 0, 0, DateTimeKind.Utc), null, true, 11, 9.00m, new DateTime(2025, 2, 14, 19, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 17, new DateTime(2025, 2, 18, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 22, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 73, 3.00m, new DateTime(2025, 2, 22, 15, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 18, new DateTime(2025, 2, 1, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 3, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 16, 6.00m, new DateTime(2025, 2, 3, 12, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 19, new DateTime(2025, 2, 7, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 11, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 79, 6.00m, new DateTime(2025, 2, 11, 8, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 20, new DateTime(2025, 2, 18, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 19, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 21, 9.00m, new DateTime(2025, 2, 19, 16, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 21, new DateTime(2025, 2, 24, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 27, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 84, 3.00m, new DateTime(2025, 2, 27, 13, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 22, new DateTime(2025, 2, 7, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 8, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 27, 3.00m, new DateTime(2025, 2, 8, 9, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 23, new DateTime(2025, 2, 13, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 16, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 90, 6.00m, new DateTime(2025, 2, 16, 18, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 24, new DateTime(2025, 2, 23, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 24, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 32, 13.50m, new DateTime(2025, 2, 24, 14, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 25, new DateTime(2025, 2, 3, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 5, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 95, 9.00m, new DateTime(2025, 2, 5, 10, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 26, new DateTime(2025, 2, 9, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 13, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 38, 4.50m, new DateTime(2025, 2, 13, 19, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 27, new DateTime(2025, 2, 18, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 20, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 100, 2.25m, new DateTime(2025, 2, 20, 15, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 28, new DateTime(2025, 1, 28, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 1, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 43, 9.00m, new DateTime(2025, 2, 1, 12, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 29, new DateTime(2025, 2, 7, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 9, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 106, 9.00m, new DateTime(2025, 2, 9, 8, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 30, new DateTime(2025, 2, 13, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 17, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 48, 13.50m, new DateTime(2025, 2, 17, 16, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 31, new DateTime(2025, 3, 24, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 25, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 111, 3.00m, new DateTime(2025, 3, 25, 13, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 32, new DateTime(2025, 3, 3, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 6, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 54, 9.00m, new DateTime(2025, 3, 6, 9, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 33, new DateTime(2025, 3, 13, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 14, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 116, 6.00m, new DateTime(2025, 3, 14, 18, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 34, new DateTime(2025, 3, 19, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 22, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 59, 13.50m, new DateTime(2025, 3, 22, 14, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 35, new DateTime(2025, 3, 2, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 3, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 2, 3.00m, new DateTime(2025, 3, 3, 10, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 36, new DateTime(2025, 3, 9, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 11, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 65, 3.00m, new DateTime(2025, 3, 11, 19, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 37, new DateTime(2025, 3, 15, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 19, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 7, 7.20m, new DateTime(2025, 3, 19, 15, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 38, new DateTime(2025, 3, 25, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 27, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 70, 6.75m, new DateTime(2025, 3, 27, 11, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 39, new DateTime(2025, 3, 4, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 8, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 13, 9.00m, new DateTime(2025, 3, 8, 8, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 40, new DateTime(2025, 3, 13, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 15, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 75, 3.00m, new DateTime(2025, 3, 15, 16, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 41, new DateTime(2025, 3, 20, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 23, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 18, 3.00m, new DateTime(2025, 3, 23, 13, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 42, new DateTime(2025, 3, 3, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 4, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 81, 6.00m, new DateTime(2025, 3, 4, 9, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 43, new DateTime(2025, 3, 9, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 12, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 23, 9.00m, new DateTime(2025, 3, 12, 17, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 44, new DateTime(2025, 3, 19, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 20, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 86, 9.00m, new DateTime(2025, 3, 20, 14, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 45, new DateTime(2025, 2, 26, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 1, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 29, 3.60m, new DateTime(2025, 3, 1, 10, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 46, new DateTime(2025, 3, 5, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 9, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 91, 6.00m, new DateTime(2025, 3, 9, 19, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 47, new DateTime(2025, 3, 15, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 17, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 34, 9.00m, new DateTime(2025, 3, 17, 15, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 48, new DateTime(2025, 3, 21, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 25, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 97, 10.80m, new DateTime(2025, 3, 25, 11, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 49, new DateTime(2025, 4, 4, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 6, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 40, 4.50m, new DateTime(2025, 4, 6, 8, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 50, new DateTime(2025, 4, 10, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 14, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 102, 3.00m, new DateTime(2025, 4, 14, 16, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 51, new DateTime(2025, 4, 21, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 22, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 45, 9.00m, new DateTime(2025, 4, 22, 12, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 52, new DateTime(2025, 3, 31, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 3, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 108, 6.00m, new DateTime(2025, 4, 3, 9, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 53, new DateTime(2025, 4, 9, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 10, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 50, 13.50m, new DateTime(2025, 4, 10, 17, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 54, new DateTime(2025, 4, 15, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 18, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 113, 3.00m, new DateTime(2025, 4, 18, 14, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 55, new DateTime(2025, 4, 25, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 26, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 56, 4.50m, new DateTime(2025, 4, 26, 10, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 56, new DateTime(2025, 4, 5, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 7, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 118, 6.00m, new DateTime(2025, 4, 7, 18, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 57, new DateTime(2025, 4, 11, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 15, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 61, 9.00m, new DateTime(2025, 4, 15, 15, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 58, new DateTime(2025, 4, 21, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 23, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 4, 9.00m, new DateTime(2025, 4, 23, 11, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 59, new DateTime(2025, 3, 31, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 4, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 66, 3.00m, new DateTime(2025, 4, 4, 8, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 60, new DateTime(2025, 4, 10, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 12, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 9, 6.00m, new DateTime(2025, 4, 12, 16, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 61, new DateTime(2025, 4, 17, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 20, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 72, 6.00m, new DateTime(2025, 4, 20, 12, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 62, new DateTime(2025, 3, 31, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 1, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 14, 10.80m, new DateTime(2025, 4, 1, 9, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 63, new DateTime(2025, 4, 6, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 9, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 77, 3.00m, new DateTime(2025, 4, 9, 17, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 64, new DateTime(2025, 4, 16, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 17, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 20, 3.00m, new DateTime(2025, 4, 17, 14, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 65, new DateTime(2025, 4, 22, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 25, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 83, 6.00m, new DateTime(2025, 4, 25, 10, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 66, new DateTime(2025, 4, 4, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 5, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 25, 4.50m, new DateTime(2025, 4, 5, 18, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 67, new DateTime(2025, 4, 11, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 13, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 88, 9.00m, new DateTime(2025, 4, 13, 15, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 68, new DateTime(2025, 4, 17, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 21, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 31, 4.50m, new DateTime(2025, 4, 21, 11, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 69, new DateTime(2025, 4, 30, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 2, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 93, 3.00m, new DateTime(2025, 5, 2, 19, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 70, new DateTime(2025, 5, 6, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 10, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 36, 9.00m, new DateTime(2025, 5, 10, 16, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 71, new DateTime(2025, 5, 16, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 18, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 99, 9.00m, new DateTime(2025, 5, 18, 12, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 72, new DateTime(2025, 5, 23, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 26, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 41, 13.50m, new DateTime(2025, 5, 26, 9, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 73, new DateTime(2025, 5, 6, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 7, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 104, 3.60m, new DateTime(2025, 5, 7, 17, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 74, new DateTime(2025, 5, 12, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 15, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 47, 9.00m, new DateTime(2025, 5, 15, 13, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 75, new DateTime(2025, 5, 22, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 23, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 109, 6.00m, new DateTime(2025, 5, 23, 10, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 76, new DateTime(2025, 5, 1, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 4, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 52, 13.50m, new DateTime(2025, 5, 4, 18, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 77, new DateTime(2025, 5, 8, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 12, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 115, 6.75m, new DateTime(2025, 5, 12, 15, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 78, new DateTime(2025, 5, 18, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 20, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 58, 4.50m, new DateTime(2025, 5, 20, 11, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 79, new DateTime(2025, 5, 23, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 27, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 120, 6.00m, new DateTime(2025, 5, 27, 19, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 80, new DateTime(2025, 5, 6, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 8, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 63, 6.00m, new DateTime(2025, 5, 8, 16, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 81, new DateTime(2025, 5, 12, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 16, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 6, 9.00m, new DateTime(2025, 5, 16, 12, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 82, new DateTime(2025, 5, 23, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 24, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 68, 3.00m, new DateTime(2025, 5, 24, 9, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 83, new DateTime(2025, 5, 2, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 5, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 11, 3.00m, new DateTime(2025, 5, 5, 17, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 84, new DateTime(2025, 5, 12, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 13, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 74, 7.20m, new DateTime(2025, 5, 13, 13, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 85, new DateTime(2025, 5, 18, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 21, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 16, 9.00m, new DateTime(2025, 5, 21, 10, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 86, new DateTime(2025, 5, 1, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 2, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 79, 9.00m, new DateTime(2025, 5, 2, 18, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 87, new DateTime(2025, 5, 8, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 10, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 22, 3.60m, new DateTime(2025, 5, 10, 14, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 88, new DateTime(2025, 5, 14, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 18, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 84, 6.00m, new DateTime(2025, 5, 18, 11, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 89, new DateTime(2025, 5, 24, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 26, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 27, 6.00m, new DateTime(2025, 5, 26, 19, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 90, new DateTime(2025, 5, 3, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 7, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 90, 9.00m, new DateTime(2025, 5, 7, 16, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 91, new DateTime(2025, 6, 12, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 14, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 33, 13.50m, new DateTime(2025, 6, 14, 12, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 92, new DateTime(2025, 6, 19, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 22, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 95, 3.00m, new DateTime(2025, 6, 22, 8, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 93, new DateTime(2025, 6, 2, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 3, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 38, 9.00m, new DateTime(2025, 6, 3, 17, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 94, new DateTime(2025, 6, 8, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 11, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 101, 6.00m, new DateTime(2025, 6, 11, 13, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 95, new DateTime(2025, 6, 18, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 19, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 43, 13.50m, new DateTime(2025, 6, 19, 10, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 96, new DateTime(2025, 6, 24, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 27, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 106, 3.00m, new DateTime(2025, 6, 27, 18, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 97, new DateTime(2025, 6, 7, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 8, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 49, 4.50m, new DateTime(2025, 6, 8, 14, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 98, new DateTime(2025, 6, 14, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 16, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 111, 6.00m, new DateTime(2025, 6, 16, 11, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 99, new DateTime(2025, 6, 20, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 24, 22, 0, 0, 0, DateTimeKind.Utc), null, true, 54, 13.50m, new DateTime(2025, 6, 24, 19, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 100, new DateTime(2025, 6, 3, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 5, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 117, 9.00m, new DateTime(2025, 6, 5, 16, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 101, new DateTime(2025, 6, 9, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 13, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 59, 4.50m, new DateTime(2025, 6, 13, 12, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 102, new DateTime(2025, 6, 19, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 21, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 2, 3.00m, new DateTime(2025, 6, 21, 8, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 103, new DateTime(2025, 5, 30, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 2, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 65, 6.00m, new DateTime(2025, 6, 2, 17, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 104, new DateTime(2025, 6, 8, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 9, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 8, 9.00m, new DateTime(2025, 6, 9, 13, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 105, new DateTime(2025, 6, 14, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 17, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 70, 6.75m, new DateTime(2025, 6, 17, 9, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 106, new DateTime(2025, 6, 24, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 25, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 13, 3.00m, new DateTime(2025, 6, 25, 18, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 107, new DateTime(2025, 6, 3, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 6, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 76, 6.00m, new DateTime(2025, 6, 6, 14, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 108, new DateTime(2025, 6, 10, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 14, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 18, 6.00m, new DateTime(2025, 6, 14, 11, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 109, new DateTime(2025, 6, 20, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 22, 22, 0, 0, 0, DateTimeKind.Utc), null, true, 81, 9.00m, new DateTime(2025, 6, 22, 19, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 110, new DateTime(2025, 5, 30, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 3, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 24, 3.00m, new DateTime(2025, 6, 3, 15, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 111, new DateTime(2025, 6, 9, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 11, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 86, 3.00m, new DateTime(2025, 6, 11, 12, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 112, new DateTime(2025, 6, 15, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 19, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 29, 7.20m, new DateTime(2025, 6, 19, 8, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 113, new DateTime(2025, 6, 26, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 27, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 92, 9.00m, new DateTime(2025, 6, 27, 17, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 114, new DateTime(2025, 6, 5, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 8, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 34, 13.50m, new DateTime(2025, 6, 8, 13, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 115, new DateTime(2025, 7, 15, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 16, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 97, 3.60m, new DateTime(2025, 7, 16, 9, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 116, new DateTime(2025, 7, 21, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 24, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 40, 4.50m, new DateTime(2025, 7, 24, 18, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 117, new DateTime(2025, 7, 3, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 4, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 103, 6.00m, new DateTime(2025, 7, 4, 14, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 118, new DateTime(2025, 7, 10, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 12, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 45, 13.50m, new DateTime(2025, 7, 12, 10, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 119, new DateTime(2025, 7, 16, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 20, 22, 0, 0, 0, DateTimeKind.Utc), null, true, 108, 9.00m, new DateTime(2025, 7, 20, 19, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 120, new DateTime(2025, 6, 29, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 1, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 51, 4.50m, new DateTime(2025, 7, 1, 15, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 121, new DateTime(2025, 7, 5, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 9, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 113, 6.00m, new DateTime(2025, 7, 9, 12, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 122, new DateTime(2025, 7, 15, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 17, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 56, 9.00m, new DateTime(2025, 7, 17, 8, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 123, new DateTime(2025, 7, 22, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 25, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 119, 10.80m, new DateTime(2025, 7, 25, 16, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 124, new DateTime(2025, 7, 5, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 6, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 61, 3.00m, new DateTime(2025, 7, 6, 13, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 125, new DateTime(2025, 7, 11, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 14, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 4, 3.00m, new DateTime(2025, 7, 14, 9, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 126, new DateTime(2025, 7, 21, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 22, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 67, 7.20m, new DateTime(2025, 7, 22, 18, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 127, new DateTime(2025, 6, 30, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 3, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 9, 6.00m, new DateTime(2025, 7, 3, 14, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 128, new DateTime(2025, 7, 7, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 11, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 72, 9.00m, new DateTime(2025, 7, 11, 10, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 129, new DateTime(2025, 7, 17, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 19, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 15, 3.00m, new DateTime(2025, 7, 19, 19, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 130, new DateTime(2025, 7, 22, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 26, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 77, 3.00m, new DateTime(2025, 7, 26, 15, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 131, new DateTime(2025, 7, 5, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 7, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 20, 6.00m, new DateTime(2025, 7, 7, 12, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 132, new DateTime(2025, 7, 11, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 15, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 83, 9.00m, new DateTime(2025, 7, 15, 8, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 133, new DateTime(2025, 7, 21, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 23, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 26, 9.00m, new DateTime(2025, 7, 23, 16, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 134, new DateTime(2025, 7, 1, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 4, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 88, 3.00m, new DateTime(2025, 7, 4, 13, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 135, new DateTime(2025, 7, 11, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 12, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 31, 9.00m, new DateTime(2025, 7, 12, 9, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 136, new DateTime(2025, 7, 17, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 20, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 94, 6.00m, new DateTime(2025, 7, 20, 17, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 137, new DateTime(2025, 6, 30, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 1, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 36, 13.50m, new DateTime(2025, 7, 1, 14, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 138, new DateTime(2025, 7, 6, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 9, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 99, 3.00m, new DateTime(2025, 7, 9, 10, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 139, new DateTime(2025, 7, 13, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 17, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 42, 4.50m, new DateTime(2025, 7, 17, 19, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 140, new DateTime(2025, 7, 23, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 25, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 104, 7.20m, new DateTime(2025, 7, 25, 15, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 141, new DateTime(2025, 8, 2, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 6, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 47, 9.00m, new DateTime(2025, 8, 6, 11, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 142, new DateTime(2025, 8, 12, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 14, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 110, 9.00m, new DateTime(2025, 8, 14, 8, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 143, new DateTime(2025, 8, 17, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 21, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 52, 4.50m, new DateTime(2025, 8, 21, 16, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 144, new DateTime(2025, 8, 1, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 2, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 115, 2.25m, new DateTime(2025, 8, 2, 13, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 145, new DateTime(2025, 8, 7, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 10, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 58, 9.00m, new DateTime(2025, 8, 10, 9, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 146, new DateTime(2025, 8, 17, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 18, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 1, 9.00m, new DateTime(2025, 8, 18, 17, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 147, new DateTime(2025, 8, 23, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 26, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 63, 9.00m, new DateTime(2025, 8, 26, 14, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 148, new DateTime(2025, 8, 6, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 7, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 6, 3.00m, new DateTime(2025, 8, 7, 10, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 149, new DateTime(2025, 8, 13, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 15, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 69, 6.00m, new DateTime(2025, 8, 15, 19, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 150, new DateTime(2025, 8, 19, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 23, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 11, 6.00m, new DateTime(2025, 8, 23, 15, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 151, new DateTime(2025, 8, 2, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 4, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 74, 10.80m, new DateTime(2025, 8, 4, 11, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 152, new DateTime(2025, 8, 8, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 12, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 17, 3.00m, new DateTime(2025, 8, 12, 8, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 153, new DateTime(2025, 8, 18, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 20, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 79, 3.00m, new DateTime(2025, 8, 20, 16, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 154, new DateTime(2025, 7, 29, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 1, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 22, 7.20m, new DateTime(2025, 8, 1, 12, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 155, new DateTime(2025, 8, 8, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 9, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 85, 4.50m, new DateTime(2025, 8, 9, 9, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 156, new DateTime(2025, 8, 13, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 16, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 27, 9.00m, new DateTime(2025, 8, 16, 17, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 157, new DateTime(2025, 8, 23, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 24, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 90, 3.00m, new DateTime(2025, 8, 24, 14, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 158, new DateTime(2025, 8, 2, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 5, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 33, 4.50m, new DateTime(2025, 8, 5, 10, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 159, new DateTime(2025, 8, 9, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 13, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 96, 6.00m, new DateTime(2025, 8, 13, 18, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 160, new DateTime(2025, 8, 19, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 21, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 38, 13.50m, new DateTime(2025, 8, 21, 15, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 161, new DateTime(2025, 7, 29, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 2, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 101, 9.00m, new DateTime(2025, 8, 2, 11, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 162, new DateTime(2025, 8, 8, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 10, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 44, 4.50m, new DateTime(2025, 8, 10, 8, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 163, new DateTime(2025, 8, 14, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 18, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 106, 6.00m, new DateTime(2025, 8, 18, 16, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 164, new DateTime(2025, 8, 25, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 26, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 49, 9.00m, new DateTime(2025, 8, 26, 12, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 165, new DateTime(2025, 8, 4, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 7, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 112, 10.80m, new DateTime(2025, 8, 7, 9, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 166, new DateTime(2025, 8, 14, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 15, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 54, 13.50m, new DateTime(2025, 8, 15, 17, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 167, new DateTime(2025, 8, 20, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 23, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 117, 3.00m, new DateTime(2025, 8, 23, 13, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 168, new DateTime(2025, 8, 3, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 4, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 60, 9.00m, new DateTime(2025, 8, 4, 10, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 169, new DateTime(2025, 9, 8, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 11, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 2, 6.00m, new DateTime(2025, 9, 11, 18, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 170, new DateTime(2025, 9, 15, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 19, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 65, 9.00m, new DateTime(2025, 9, 19, 15, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 171, new DateTime(2025, 9, 25, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 27, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 8, 3.00m, new DateTime(2025, 9, 27, 11, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 172, new DateTime(2025, 9, 4, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 8, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 71, 3.00m, new DateTime(2025, 9, 8, 19, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 173, new DateTime(2025, 9, 14, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 16, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 13, 6.00m, new DateTime(2025, 9, 16, 16, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 174, new DateTime(2025, 9, 20, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 24, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 76, 9.00m, new DateTime(2025, 9, 24, 12, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 175, new DateTime(2025, 9, 4, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 5, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 19, 9.00m, new DateTime(2025, 9, 5, 9, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 176, new DateTime(2025, 9, 10, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 13, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 81, 3.00m, new DateTime(2025, 9, 13, 17, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 177, new DateTime(2025, 9, 20, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 21, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 24, 6.00m, new DateTime(2025, 9, 21, 13, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 178, new DateTime(2025, 8, 30, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 2, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 87, 6.00m, new DateTime(2025, 9, 2, 10, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 179, new DateTime(2025, 9, 9, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 10, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 29, 10.80m, new DateTime(2025, 9, 10, 18, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 180, new DateTime(2025, 9, 16, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 18, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 92, 9.00m, new DateTime(2025, 9, 18, 15, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 181, new DateTime(2025, 9, 22, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 26, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 35, 4.50m, new DateTime(2025, 9, 26, 11, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 182, new DateTime(2025, 9, 4, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 6, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 97, 7.20m, new DateTime(2025, 9, 6, 19, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 183, new DateTime(2025, 9, 10, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 14, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 40, 9.00m, new DateTime(2025, 9, 14, 16, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 184, new DateTime(2025, 9, 20, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 22, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 103, 9.00m, new DateTime(2025, 9, 22, 12, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 185, new DateTime(2025, 8, 31, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 3, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 45, 4.50m, new DateTime(2025, 9, 3, 8, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 186, new DateTime(2025, 9, 10, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 11, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 108, 3.00m, new DateTime(2025, 9, 11, 17, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 187, new DateTime(2025, 9, 16, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 19, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 51, 9.00m, new DateTime(2025, 9, 19, 13, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 188, new DateTime(2025, 9, 26, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 27, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 114, 9.00m, new DateTime(2025, 9, 27, 10, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 189, new DateTime(2025, 9, 5, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 8, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 56, 13.50m, new DateTime(2025, 9, 8, 18, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 190, new DateTime(2025, 9, 12, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 16, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 119, 3.60m, new DateTime(2025, 9, 16, 14, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 191, new DateTime(2025, 9, 22, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 24, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 62, 3.00m, new DateTime(2025, 9, 24, 11, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 192, new DateTime(2025, 9, 1, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 5, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 4, 6.00m, new DateTime(2025, 9, 5, 19, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 193, new DateTime(2025, 9, 11, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 13, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 67, 10.80m, new DateTime(2025, 9, 13, 16, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 194, new DateTime(2025, 9, 16, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 20, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 10, 6.75m, new DateTime(2025, 9, 20, 12, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 195, new DateTime(2025, 8, 31, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 1, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 72, 3.00m, new DateTime(2025, 9, 1, 8, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 196, new DateTime(2025, 9, 6, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 9, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 15, 6.00m, new DateTime(2025, 9, 9, 17, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 197, new DateTime(2025, 9, 16, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 17, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 78, 6.00m, new DateTime(2025, 9, 17, 13, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 198, new DateTime(2025, 9, 22, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 25, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 20, 9.00m, new DateTime(2025, 9, 25, 10, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 199, new DateTime(2025, 10, 5, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 6, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 83, 3.00m, new DateTime(2025, 10, 6, 18, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 200, new DateTime(2025, 10, 11, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 14, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 26, 3.00m, new DateTime(2025, 10, 14, 14, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 201, new DateTime(2025, 10, 18, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 22, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 89, 7.20m, new DateTime(2025, 10, 22, 11, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 202, new DateTime(2025, 10, 1, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 3, 22, 0, 0, 0, DateTimeKind.Utc), null, true, 31, 13.50m, new DateTime(2025, 10, 3, 19, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 203, new DateTime(2025, 10, 7, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 11, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 94, 9.00m, new DateTime(2025, 10, 11, 15, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 204, new DateTime(2025, 10, 17, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 19, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 37, 4.50m, new DateTime(2025, 10, 19, 12, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 205, new DateTime(2025, 10, 23, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 27, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 99, 3.00m, new DateTime(2025, 10, 27, 8, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 206, new DateTime(2025, 10, 7, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 8, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 42, 9.00m, new DateTime(2025, 10, 8, 17, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 207, new DateTime(2025, 10, 12, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 15, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 105, 9.00m, new DateTime(2025, 10, 15, 13, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 208, new DateTime(2025, 10, 22, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 23, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 47, 13.50m, new DateTime(2025, 10, 23, 9, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 209, new DateTime(2025, 10, 1, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 4, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 110, 3.00m, new DateTime(2025, 10, 4, 18, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 210, new DateTime(2025, 10, 11, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 12, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 53, 9.00m, new DateTime(2025, 10, 12, 14, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 211, new DateTime(2025, 10, 18, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 20, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 115, 4.50m, new DateTime(2025, 10, 20, 11, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 212, new DateTime(2025, 9, 27, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 1, 22, 0, 0, 0, DateTimeKind.Utc), null, true, 58, 13.50m, new DateTime(2025, 10, 1, 19, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 213, new DateTime(2025, 10, 7, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 9, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 1, 3.00m, new DateTime(2025, 10, 9, 15, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 214, new DateTime(2025, 10, 13, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 17, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 64, 3.00m, new DateTime(2025, 10, 17, 12, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 215, new DateTime(2025, 10, 23, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 25, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 6, 6.00m, new DateTime(2025, 10, 25, 8, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 216, new DateTime(2025, 10, 3, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 6, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 69, 6.00m, new DateTime(2025, 10, 6, 16, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 217, new DateTime(2025, 10, 13, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 14, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 12, 9.00m, new DateTime(2025, 10, 14, 13, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 218, new DateTime(2025, 10, 19, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 22, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 74, 3.60m, new DateTime(2025, 10, 22, 9, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 219, new DateTime(2025, 10, 2, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 3, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 17, 3.00m, new DateTime(2025, 10, 3, 18, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 220, new DateTime(2025, 10, 7, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 10, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 80, 6.00m, new DateTime(2025, 10, 10, 14, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 221, new DateTime(2025, 10, 14, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 18, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 22, 10.80m, new DateTime(2025, 10, 18, 10, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 222, new DateTime(2025, 10, 24, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 26, 22, 0, 0, 0, DateTimeKind.Utc), null, true, 85, 6.75m, new DateTime(2025, 10, 26, 19, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 223, new DateTime(2025, 10, 3, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 7, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 28, 3.00m, new DateTime(2025, 10, 7, 15, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 224, new DateTime(2025, 10, 13, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 15, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 90, 6.00m, new DateTime(2025, 10, 15, 12, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 225, new DateTime(2025, 10, 19, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 23, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 33, 9.00m, new DateTime(2025, 10, 23, 8, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 226, new DateTime(2025, 10, 3, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 4, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 96, 9.00m, new DateTime(2025, 10, 4, 16, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 227, new DateTime(2025, 10, 9, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 12, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 39, 4.50m, new DateTime(2025, 10, 12, 13, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 228, new DateTime(2025, 10, 19, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 20, 10, 0, 0, 0, DateTimeKind.Utc), null, true, 101, 3.00m, new DateTime(2025, 10, 20, 9, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 229, new DateTime(2025, 9, 28, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 1, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 44, 9.00m, new DateTime(2025, 10, 1, 18, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 230, new DateTime(2025, 10, 8, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 9, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 107, 6.00m, new DateTime(2025, 10, 9, 14, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 231, new DateTime(2025, 11, 15, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 17, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 49, 13.50m, new DateTime(2025, 11, 17, 10, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 232, new DateTime(2025, 11, 21, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 25, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 112, 3.60m, new DateTime(2025, 11, 25, 19, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 233, new DateTime(2025, 11, 3, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 5, 16, 0, 0, 0, DateTimeKind.Utc), null, true, 55, 4.50m, new DateTime(2025, 11, 5, 15, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 234, new DateTime(2025, 11, 9, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 13, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 117, 6.00m, new DateTime(2025, 11, 13, 11, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 235, new DateTime(2025, 11, 19, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 21, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 60, 13.50m, new DateTime(2025, 11, 21, 8, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 236, new DateTime(2025, 10, 29, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 2, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 3, 9.00m, new DateTime(2025, 11, 2, 16, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 237, new DateTime(2025, 11, 9, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 10, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 65, 3.00m, new DateTime(2025, 11, 10, 13, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 238, new DateTime(2025, 11, 15, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 18, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 8, 6.00m, new DateTime(2025, 11, 18, 9, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 239, new DateTime(2025, 11, 25, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 26, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 71, 6.00m, new DateTime(2025, 11, 26, 17, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 240, new DateTime(2025, 11, 4, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 7, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 13, 9.00m, new DateTime(2025, 11, 7, 14, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 241, new DateTime(2025, 11, 14, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 15, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 76, 9.00m, new DateTime(2025, 11, 15, 10, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 242, new DateTime(2025, 11, 21, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 23, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 19, 3.00m, new DateTime(2025, 11, 23, 19, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 243, new DateTime(2025, 10, 31, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 4, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 82, 7.20m, new DateTime(2025, 11, 4, 15, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 244, new DateTime(2025, 11, 10, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 12, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 24, 6.00m, new DateTime(2025, 11, 12, 11, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 245, new DateTime(2025, 11, 16, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 20, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 87, 9.00m, new DateTime(2025, 11, 20, 8, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 246, new DateTime(2025, 11, 25, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 27, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 30, 3.00m, new DateTime(2025, 11, 27, 16, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 247, new DateTime(2025, 11, 5, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 8, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 92, 3.00m, new DateTime(2025, 11, 8, 13, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 248, new DateTime(2025, 11, 15, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 16, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 35, 9.00m, new DateTime(2025, 11, 16, 9, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 249, new DateTime(2025, 11, 21, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 24, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 98, 9.00m, new DateTime(2025, 11, 24, 17, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 250, new DateTime(2025, 11, 4, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 5, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 40, 13.50m, new DateTime(2025, 11, 5, 14, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 251, new DateTime(2025, 11, 10, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 13, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 103, 3.00m, new DateTime(2025, 11, 13, 10, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 252, new DateTime(2025, 11, 17, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 21, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 46, 9.00m, new DateTime(2025, 11, 21, 18, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 253, new DateTime(2025, 10, 31, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 2, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 108, 6.00m, new DateTime(2025, 11, 2, 15, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 254, new DateTime(2025, 11, 6, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 10, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 51, 13.50m, new DateTime(2025, 11, 10, 11, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 255, new DateTime(2025, 11, 16, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 18, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 114, 9.00m, new DateTime(2025, 11, 18, 8, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 256, new DateTime(2025, 11, 22, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 26, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 57, 4.50m, new DateTime(2025, 11, 26, 16, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 257, new DateTime(2025, 11, 6, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 7, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 119, 7.20m, new DateTime(2025, 11, 7, 12, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 258, new DateTime(2025, 11, 12, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 15, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 62, 6.00m, new DateTime(2025, 11, 15, 9, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 259, new DateTime(2025, 11, 21, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 22, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 5, 9.00m, new DateTime(2025, 11, 22, 17, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 260, new DateTime(2025, 10, 31, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 3, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 67, 3.60m, new DateTime(2025, 11, 3, 14, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 261, new DateTime(2025, 11, 10, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 11, 11, 0, 0, 0, DateTimeKind.Utc), null, true, 10, 2.25m, new DateTime(2025, 11, 11, 10, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 262, new DateTime(2025, 11, 17, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 19, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 73, 6.00m, new DateTime(2025, 11, 19, 18, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 263, new DateTime(2025, 11, 23, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 27, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 15, 9.00m, new DateTime(2025, 11, 27, 15, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 264, new DateTime(2025, 11, 6, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 8, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 78, 9.00m, new DateTime(2025, 11, 8, 11, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 265, new DateTime(2025, 12, 12, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 16, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 21, 3.00m, new DateTime(2025, 12, 16, 19, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 266, new DateTime(2025, 12, 22, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 24, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 83, 6.00m, new DateTime(2025, 12, 24, 16, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 267, new DateTime(2025, 12, 1, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 5, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 26, 6.00m, new DateTime(2025, 12, 5, 12, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 268, new DateTime(2025, 12, 12, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 13, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 89, 10.80m, new DateTime(2025, 12, 13, 9, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 269, new DateTime(2025, 12, 18, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 21, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 32, 13.50m, new DateTime(2025, 12, 21, 17, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 270, new DateTime(2025, 12, 1, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 2, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 94, 3.00m, new DateTime(2025, 12, 2, 13, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 271, new DateTime(2025, 12, 7, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 10, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 37, 9.00m, new DateTime(2025, 12, 10, 10, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 272, new DateTime(2025, 12, 16, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 17, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 100, 4.50m, new DateTime(2025, 12, 17, 18, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 273, new DateTime(2025, 12, 23, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 25, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 42, 13.50m, new DateTime(2025, 12, 25, 15, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 274, new DateTime(2025, 12, 2, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 6, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 105, 3.00m, new DateTime(2025, 12, 6, 11, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 275, new DateTime(2025, 12, 12, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 14, 20, 0, 0, 0, DateTimeKind.Utc), null, true, 48, 4.50m, new DateTime(2025, 12, 14, 19, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 276, new DateTime(2025, 12, 18, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 22, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 110, 6.00m, new DateTime(2025, 12, 22, 16, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 277, new DateTime(2025, 12, 1, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 3, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 53, 13.50m, new DateTime(2025, 12, 3, 12, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 278, new DateTime(2025, 12, 8, 9, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 11, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 116, 9.00m, new DateTime(2025, 12, 11, 9, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 279, new DateTime(2025, 12, 18, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 19, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 58, 4.50m, new DateTime(2025, 12, 19, 17, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 280, new DateTime(2025, 12, 24, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 27, 14, 0, 0, 0, DateTimeKind.Utc), null, true, 1, 3.00m, new DateTime(2025, 12, 27, 13, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 281, new DateTime(2025, 12, 7, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 8, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 64, 6.00m, new DateTime(2025, 12, 8, 10, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 282, new DateTime(2025, 12, 13, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 16, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 7, 10.80m, new DateTime(2025, 12, 16, 18, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 283, new DateTime(2025, 12, 20, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 24, 17, 0, 0, 0, DateTimeKind.Utc), null, true, 69, 9.00m, new DateTime(2025, 12, 24, 14, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 284, new DateTime(2025, 12, 3, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 5, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 12, 3.00m, new DateTime(2025, 12, 5, 11, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 285, new DateTime(2025, 12, 8, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 12, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 75, 6.00m, new DateTime(2025, 12, 12, 19, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 286, new DateTime(2025, 12, 18, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 20, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 17, 6.00m, new DateTime(2025, 12, 20, 16, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 287, new DateTime(2025, 11, 27, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 1, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 80, 9.00m, new DateTime(2025, 12, 1, 12, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 288, new DateTime(2025, 12, 8, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 9, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 23, 3.00m, new DateTime(2025, 12, 9, 8, 0, 0, 0, DateTimeKind.Utc), 12, 13 },
                    { 289, new DateTime(2025, 12, 14, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 17, 18, 0, 0, 0, DateTimeKind.Utc), null, true, 85, 2.25m, new DateTime(2025, 12, 17, 17, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 290, new DateTime(2025, 12, 24, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 25, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 28, 6.00m, new DateTime(2025, 12, 25, 13, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 291, new DateTime(2025, 12, 3, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 6, 13, 0, 0, 0, DateTimeKind.Utc), null, true, 91, 9.00m, new DateTime(2025, 12, 6, 10, 0, 0, 0, DateTimeKind.Utc), 3, 4 },
                    { 292, new DateTime(2025, 12, 13, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 14, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 33, 13.50m, new DateTime(2025, 12, 14, 18, 0, 0, 0, DateTimeKind.Utc), 4, 5 },
                    { 293, new DateTime(2025, 12, 20, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 22, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 96, 3.00m, new DateTime(2025, 12, 22, 14, 0, 0, 0, DateTimeKind.Utc), 5, 6 },
                    { 294, new DateTime(2025, 11, 29, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 3, 12, 0, 0, 0, DateTimeKind.Utc), null, true, 39, 4.50m, new DateTime(2025, 12, 3, 11, 0, 0, 0, DateTimeKind.Utc), 6, 7 },
                    { 295, new DateTime(2025, 12, 9, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 11, 21, 0, 0, 0, DateTimeKind.Utc), null, true, 102, 6.00m, new DateTime(2025, 12, 11, 19, 0, 0, 0, DateTimeKind.Utc), 7, 8 },
                    { 296, new DateTime(2025, 12, 15, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 19, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 44, 13.50m, new DateTime(2025, 12, 19, 16, 0, 0, 0, DateTimeKind.Utc), 8, 9 },
                    { 297, new DateTime(2025, 12, 24, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 26, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 107, 9.00m, new DateTime(2025, 12, 26, 12, 0, 0, 0, DateTimeKind.Utc), 9, 10 },
                    { 298, new DateTime(2025, 12, 4, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 7, 9, 0, 0, 0, DateTimeKind.Utc), null, true, 50, 4.50m, new DateTime(2025, 12, 7, 8, 0, 0, 0, DateTimeKind.Utc), 10, 11 },
                    { 299, new DateTime(2025, 12, 14, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 15, 19, 0, 0, 0, DateTimeKind.Utc), null, true, 112, 7.20m, new DateTime(2025, 12, 15, 17, 0, 0, 0, DateTimeKind.Utc), 11, 12 },
                    { 300, new DateTime(2025, 12, 20, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 23, 15, 0, 0, 0, DateTimeKind.Utc), null, true, 55, 9.00m, new DateTime(2025, 12, 23, 13, 0, 0, 0, DateTimeKind.Utc), 12, 13 }
                });

            migrationBuilder.InsertData(
                table: "ParkingSessions",
                columns: new[] { "Id", "ActualEndTime", "ActualStartTime", "ArrivalTime", "CreatedAt", "ExtraCharge", "ExtraMinutes", "ParkingReservationId" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 1, 3, 15, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 3, 12, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 3, 12, 58, 0, 0, DateTimeKind.Utc), null, null, 1 },
                    { 2, new DateTime(2025, 1, 11, 11, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 11, 9, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 11, 9, 6, 0, 0, DateTimeKind.Utc), null, null, 2 },
                    { 3, new DateTime(2025, 1, 19, 19, 45, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 19, 17, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 19, 17, 59, 0, 0, DateTimeKind.Utc), 3.38m, 45, 3 },
                    { 4, new DateTime(2025, 1, 27, 15, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 27, 14, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 27, 14, 7, 0, 0, DateTimeKind.Utc), null, null, 4 },
                    { 5, new DateTime(2025, 1, 8, 12, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 8, 11, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 8, 11, 0, 0, 0, DateTimeKind.Utc), null, null, 5 },
                    { 6, new DateTime(2025, 1, 16, 23, 45, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 16, 19, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 16, 19, 7, 0, 0, DateTimeKind.Utc), 6.30m, 105, 6 },
                    { 7, new DateTime(2025, 1, 24, 15, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 24, 15, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 24, 15, 0, 0, 0, DateTimeKind.Utc), null, null, 7 },
                    { 8, new DateTime(2025, 1, 5, 12, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 5, 12, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 5, 12, 8, 0, 0, DateTimeKind.Utc), null, null, 8 },
                    { 9, new DateTime(2025, 1, 13, 10, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 13, 8, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 13, 8, 1, 0, 0, DateTimeKind.Utc), 4.42m, 59, 9 },
                    { 10, new DateTime(2025, 1, 21, 19, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 21, 17, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 21, 17, 9, 0, 0, DateTimeKind.Utc), null, null, 10 },
                    { 11, new DateTime(2025, 1, 2, 15, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 2, 13, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 2, 13, 2, 0, 0, DateTimeKind.Utc), null, null, 11 },
                    { 12, new DateTime(2025, 1, 10, 11, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 10, 9, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 10, 9, 9, 0, 0, DateTimeKind.Utc), 5.95m, 119, 12 },
                    { 13, new DateTime(2025, 1, 18, 18, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 18, 18, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 18, 18, 2, 0, 0, DateTimeKind.Utc), null, null, 13 },
                    { 14, new DateTime(2025, 1, 25, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 25, 13, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 1, 25, 13, 55, 0, 0, DateTimeKind.Utc), null, null, 14 },
                    { 15, new DateTime(2025, 2, 6, 15, 14, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 6, 11, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 6, 11, 3, 0, 0, DateTimeKind.Utc), 3.70m, 74, 15 },
                    { 16, new DateTime(2025, 2, 14, 22, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 14, 18, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 14, 18, 56, 0, 0, DateTimeKind.Utc), null, null, 16 },
                    { 17, new DateTime(2025, 2, 22, 15, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 22, 15, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 22, 15, 4, 0, 0, DateTimeKind.Utc), null, null, 17 },
                    { 18, new DateTime(2025, 2, 3, 14, 28, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 3, 11, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 3, 11, 56, 0, 0, DateTimeKind.Utc), 1.40m, 28, 18 },
                    { 19, new DateTime(2025, 2, 11, 9, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 11, 8, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 11, 8, 4, 0, 0, DateTimeKind.Utc), null, null, 19 },
                    { 20, new DateTime(2025, 2, 19, 18, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 19, 15, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 19, 15, 57, 0, 0, DateTimeKind.Utc), null, null, 20 },
                    { 21, new DateTime(2025, 2, 27, 15, 28, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 27, 13, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 27, 13, 5, 0, 0, DateTimeKind.Utc), 4.40m, 88, 21 },
                    { 22, new DateTime(2025, 2, 8, 9, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 8, 8, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 8, 8, 58, 0, 0, DateTimeKind.Utc), null, null, 22 },
                    { 23, new DateTime(2025, 2, 16, 19, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 16, 18, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 16, 18, 6, 0, 0, DateTimeKind.Utc), null, null, 23 },
                    { 24, new DateTime(2025, 2, 24, 17, 42, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 24, 13, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 24, 13, 58, 0, 0, DateTimeKind.Utc), 3.15m, 42, 24 },
                    { 25, new DateTime(2025, 2, 5, 12, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 5, 10, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 5, 10, 6, 0, 0, DateTimeKind.Utc), null, null, 25 },
                    { 26, new DateTime(2025, 2, 13, 19, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 13, 18, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 13, 18, 59, 0, 0, DateTimeKind.Utc), null, null, 26 },
                    { 27, new DateTime(2025, 2, 20, 17, 42, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 20, 15, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 20, 15, 7, 0, 0, DateTimeKind.Utc), 3.82m, 102, 27 },
                    { 28, new DateTime(2025, 2, 1, 13, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 1, 12, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 1, 12, 0, 0, 0, DateTimeKind.Utc), null, null, 28 },
                    { 29, new DateTime(2025, 2, 9, 10, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 9, 8, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 9, 8, 8, 0, 0, DateTimeKind.Utc), null, null, 29 },
                    { 30, new DateTime(2025, 2, 17, 19, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 2, 17, 16, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 2, 17, 16, 0, 0, 0, DateTimeKind.Utc), 4.20m, 56, 30 },
                    { 31, new DateTime(2025, 3, 25, 13, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 25, 13, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 25, 13, 8, 0, 0, DateTimeKind.Utc), null, null, 31 },
                    { 32, new DateTime(2025, 3, 6, 10, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 6, 9, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 6, 9, 1, 0, 0, DateTimeKind.Utc), null, null, 32 },
                    { 33, new DateTime(2025, 3, 14, 21, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 14, 18, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 14, 18, 9, 0, 0, DateTimeKind.Utc), 5.80m, 116, 33 },
                    { 34, new DateTime(2025, 3, 22, 16, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 22, 14, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 22, 14, 2, 0, 0, DateTimeKind.Utc), null, null, 34 },
                    { 35, new DateTime(2025, 3, 3, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 3, 9, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 3, 9, 55, 0, 0, DateTimeKind.Utc), null, null, 35 },
                    { 36, new DateTime(2025, 3, 11, 21, 11, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 11, 19, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 11, 19, 3, 0, 0, DateTimeKind.Utc), 3.55m, 71, 36 },
                    { 37, new DateTime(2025, 3, 19, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 19, 14, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 19, 14, 55, 0, 0, DateTimeKind.Utc), null, null, 37 },
                    { 38, new DateTime(2025, 3, 27, 13, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 27, 11, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 27, 11, 3, 0, 0, DateTimeKind.Utc), null, null, 38 },
                    { 39, new DateTime(2025, 3, 8, 11, 25, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 8, 7, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 8, 7, 56, 0, 0, DateTimeKind.Utc), 1.25m, 25, 39 },
                    { 40, new DateTime(2025, 3, 15, 16, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 15, 16, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 15, 16, 4, 0, 0, DateTimeKind.Utc), null, null, 40 },
                    { 41, new DateTime(2025, 3, 23, 13, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 23, 12, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 23, 12, 57, 0, 0, DateTimeKind.Utc), null, null, 41 },
                    { 42, new DateTime(2025, 3, 4, 12, 25, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 4, 9, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 4, 9, 5, 0, 0, DateTimeKind.Utc), 4.25m, 85, 42 },
                    { 43, new DateTime(2025, 3, 12, 19, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 12, 16, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 12, 16, 57, 0, 0, DateTimeKind.Utc), null, null, 43 },
                    { 44, new DateTime(2025, 3, 20, 16, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 20, 14, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 20, 14, 5, 0, 0, DateTimeKind.Utc), null, null, 44 },
                    { 45, new DateTime(2025, 3, 1, 11, 39, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 1, 9, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 1, 9, 58, 0, 0, DateTimeKind.Utc), 2.34m, 39, 45 },
                    { 46, new DateTime(2025, 3, 9, 20, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 9, 19, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 9, 19, 6, 0, 0, DateTimeKind.Utc), null, null, 46 },
                    { 47, new DateTime(2025, 3, 17, 16, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 17, 14, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 17, 14, 59, 0, 0, DateTimeKind.Utc), null, null, 47 },
                    { 48, new DateTime(2025, 3, 25, 15, 39, 0, 0, DateTimeKind.Utc), new DateTime(2025, 3, 25, 11, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 3, 25, 11, 7, 0, 0, DateTimeKind.Utc), 5.94m, 99, 48 },
                    { 49, new DateTime(2025, 4, 6, 8, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 6, 7, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 6, 7, 59, 0, 0, DateTimeKind.Utc), null, null, 49 },
                    { 50, new DateTime(2025, 4, 14, 16, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 14, 16, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 14, 16, 7, 0, 0, DateTimeKind.Utc), null, null, 50 },
                    { 51, new DateTime(2025, 4, 22, 14, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 22, 12, 0, 0, 0, DateTimeKind.Utc), 3.98m, 53, 51 },
                    { 52, new DateTime(2025, 4, 3, 10, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 3, 9, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 3, 9, 8, 0, 0, DateTimeKind.Utc), null, null, 52 },
                    { 53, new DateTime(2025, 4, 10, 19, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 10, 17, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 10, 17, 1, 0, 0, DateTimeKind.Utc), null, null, 53 },
                    { 54, new DateTime(2025, 4, 18, 16, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 18, 14, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 18, 14, 9, 0, 0, DateTimeKind.Utc), 5.65m, 113, 54 },
                    { 55, new DateTime(2025, 4, 26, 10, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 26, 10, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 26, 10, 1, 0, 0, DateTimeKind.Utc), null, null, 55 },
                    { 56, new DateTime(2025, 4, 7, 19, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 7, 18, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 7, 18, 9, 0, 0, DateTimeKind.Utc), null, null, 56 },
                    { 57, new DateTime(2025, 4, 15, 19, 7, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 15, 15, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 15, 15, 2, 0, 0, DateTimeKind.Utc), 3.35m, 67, 57 },
                    { 58, new DateTime(2025, 4, 23, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 23, 10, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 23, 10, 55, 0, 0, DateTimeKind.Utc), null, null, 58 },
                    { 59, new DateTime(2025, 4, 4, 8, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 4, 8, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 4, 8, 3, 0, 0, DateTimeKind.Utc), null, null, 59 },
                    { 60, new DateTime(2025, 4, 12, 18, 22, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 12, 15, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 12, 15, 56, 0, 0, DateTimeKind.Utc), 1.10m, 22, 60 },
                    { 61, new DateTime(2025, 4, 20, 13, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 20, 12, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 20, 12, 3, 0, 0, DateTimeKind.Utc), null, null, 61 },
                    { 62, new DateTime(2025, 4, 1, 11, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 1, 8, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 1, 8, 56, 0, 0, DateTimeKind.Utc), null, null, 62 },
                    { 63, new DateTime(2025, 4, 9, 19, 22, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 9, 17, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 9, 17, 4, 0, 0, DateTimeKind.Utc), 4.10m, 82, 63 },
                    { 64, new DateTime(2025, 4, 17, 14, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 17, 13, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 17, 13, 57, 0, 0, DateTimeKind.Utc), null, null, 64 },
                    { 65, new DateTime(2025, 4, 25, 11, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 25, 10, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 25, 10, 5, 0, 0, DateTimeKind.Utc), null, null, 65 },
                    { 66, new DateTime(2025, 4, 5, 20, 36, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 5, 17, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 5, 17, 58, 0, 0, DateTimeKind.Utc), 1.35m, 36, 66 },
                    { 67, new DateTime(2025, 4, 13, 17, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 13, 15, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 13, 15, 5, 0, 0, DateTimeKind.Utc), null, null, 67 },
                    { 68, new DateTime(2025, 4, 21, 11, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 4, 21, 10, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 4, 21, 10, 58, 0, 0, DateTimeKind.Utc), null, null, 68 },
                    { 69, new DateTime(2025, 5, 2, 21, 36, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 2, 19, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 2, 19, 6, 0, 0, DateTimeKind.Utc), 4.80m, 96, 69 },
                    { 70, new DateTime(2025, 5, 10, 17, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 10, 15, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 10, 15, 59, 0, 0, DateTimeKind.Utc), null, null, 70 },
                    { 71, new DateTime(2025, 5, 18, 14, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 18, 12, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 18, 12, 7, 0, 0, DateTimeKind.Utc), null, null, 71 },
                    { 72, new DateTime(2025, 5, 26, 12, 50, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 26, 9, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 26, 9, 0, 0, 0, DateTimeKind.Utc), 3.75m, 50, 72 },
                    { 73, new DateTime(2025, 5, 7, 17, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 7, 17, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 7, 17, 7, 0, 0, DateTimeKind.Utc), null, null, 73 },
                    { 74, new DateTime(2025, 5, 15, 14, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 15, 13, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 15, 13, 0, 0, 0, DateTimeKind.Utc), null, null, 74 },
                    { 75, new DateTime(2025, 5, 23, 13, 50, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 23, 10, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 23, 10, 8, 0, 0, DateTimeKind.Utc), 5.50m, 110, 75 },
                    { 76, new DateTime(2025, 5, 4, 20, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 4, 18, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 4, 18, 1, 0, 0, DateTimeKind.Utc), null, null, 76 },
                    { 77, new DateTime(2025, 5, 12, 17, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 12, 15, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 12, 15, 9, 0, 0, DateTimeKind.Utc), null, null, 77 },
                    { 78, new DateTime(2025, 5, 20, 13, 4, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 20, 11, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 20, 11, 2, 0, 0, DateTimeKind.Utc), 4.80m, 64, 78 },
                    { 79, new DateTime(2025, 5, 27, 20, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 27, 19, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 27, 19, 9, 0, 0, DateTimeKind.Utc), null, null, 79 },
                    { 80, new DateTime(2025, 5, 8, 17, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 8, 16, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 8, 16, 2, 0, 0, DateTimeKind.Utc), null, null, 80 },
                    { 81, new DateTime(2025, 5, 16, 15, 19, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 16, 11, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 16, 11, 55, 0, 0, DateTimeKind.Utc), 0.95m, 19, 81 },
                    { 82, new DateTime(2025, 5, 24, 9, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 24, 9, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 24, 9, 3, 0, 0, DateTimeKind.Utc), null, null, 82 },
                    { 83, new DateTime(2025, 5, 5, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 5, 16, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 5, 16, 56, 0, 0, DateTimeKind.Utc), null, null, 83 },
                    { 84, new DateTime(2025, 5, 13, 16, 19, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 13, 13, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 13, 13, 4, 0, 0, DateTimeKind.Utc), 4.74m, 79, 84 },
                    { 85, new DateTime(2025, 5, 21, 12, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 21, 9, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 21, 9, 56, 0, 0, DateTimeKind.Utc), null, null, 85 },
                    { 86, new DateTime(2025, 5, 2, 20, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 2, 18, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 2, 18, 4, 0, 0, DateTimeKind.Utc), null, null, 86 },
                    { 87, new DateTime(2025, 5, 10, 15, 33, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 10, 13, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 10, 13, 57, 0, 0, DateTimeKind.Utc), 1.98m, 33, 87 },
                    { 88, new DateTime(2025, 5, 18, 12, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 18, 11, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 18, 11, 5, 0, 0, DateTimeKind.Utc), null, null, 88 },
                    { 89, new DateTime(2025, 5, 26, 20, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 26, 18, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 26, 18, 58, 0, 0, DateTimeKind.Utc), null, null, 89 },
                    { 90, new DateTime(2025, 5, 7, 20, 33, 0, 0, DateTimeKind.Utc), new DateTime(2025, 5, 7, 16, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 5, 7, 16, 6, 0, 0, DateTimeKind.Utc), 4.65m, 93, 90 },
                    { 91, new DateTime(2025, 6, 14, 14, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 14, 11, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 14, 11, 59, 0, 0, DateTimeKind.Utc), null, null, 91 },
                    { 92, new DateTime(2025, 6, 22, 8, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 22, 8, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 22, 8, 6, 0, 0, DateTimeKind.Utc), null, null, 92 },
                    { 93, new DateTime(2025, 6, 3, 19, 47, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 3, 16, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 3, 16, 59, 0, 0, DateTimeKind.Utc), 3.52m, 47, 93 },
                    { 94, new DateTime(2025, 6, 11, 14, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 11, 13, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 11, 13, 7, 0, 0, DateTimeKind.Utc), null, null, 94 },
                    { 95, new DateTime(2025, 6, 19, 12, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 19, 10, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 19, 10, 0, 0, 0, DateTimeKind.Utc), null, null, 95 },
                    { 96, new DateTime(2025, 6, 27, 20, 47, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 27, 18, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 27, 18, 8, 0, 0, DateTimeKind.Utc), 5.35m, 107, 96 },
                    { 97, new DateTime(2025, 6, 8, 14, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 8, 14, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 8, 14, 1, 0, 0, DateTimeKind.Utc), null, null, 97 },
                    { 98, new DateTime(2025, 6, 16, 12, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 16, 11, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 16, 11, 8, 0, 0, DateTimeKind.Utc), null, null, 98 },
                    { 99, new DateTime(2025, 6, 24, 23, 1, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 24, 19, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 24, 19, 1, 0, 0, DateTimeKind.Utc), 4.58m, 61, 99 },
                    { 100, new DateTime(2025, 6, 5, 18, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 5, 16, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 5, 16, 9, 0, 0, DateTimeKind.Utc), null, null, 100 },
                    { 101, new DateTime(2025, 6, 13, 12, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 13, 12, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 13, 12, 2, 0, 0, DateTimeKind.Utc), null, null, 101 },
                    { 102, new DateTime(2025, 6, 21, 9, 16, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 21, 7, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 21, 7, 55, 0, 0, DateTimeKind.Utc), 0.80m, 16, 102 },
                    { 103, new DateTime(2025, 6, 2, 18, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 2, 17, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 2, 17, 3, 0, 0, DateTimeKind.Utc), null, null, 103 },
                    { 104, new DateTime(2025, 6, 9, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 9, 12, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 9, 12, 55, 0, 0, DateTimeKind.Utc), null, null, 104 },
                    { 105, new DateTime(2025, 6, 17, 13, 15, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 17, 9, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 17, 9, 3, 0, 0, DateTimeKind.Utc), 2.81m, 75, 105 },
                    { 106, new DateTime(2025, 6, 25, 18, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 25, 17, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 25, 17, 56, 0, 0, DateTimeKind.Utc), null, null, 106 },
                    { 107, new DateTime(2025, 6, 6, 15, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 6, 14, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 6, 14, 4, 0, 0, DateTimeKind.Utc), null, null, 107 },
                    { 108, new DateTime(2025, 6, 14, 13, 30, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 14, 10, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 14, 10, 57, 0, 0, DateTimeKind.Utc), 1.50m, 30, 108 },
                    { 109, new DateTime(2025, 6, 22, 21, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 22, 19, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 22, 19, 5, 0, 0, DateTimeKind.Utc), null, null, 109 },
                    { 110, new DateTime(2025, 6, 3, 15, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 3, 14, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 3, 14, 57, 0, 0, DateTimeKind.Utc), null, null, 110 },
                    { 111, new DateTime(2025, 6, 11, 14, 30, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 11, 12, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 11, 12, 5, 0, 0, DateTimeKind.Utc), 4.50m, 90, 111 },
                    { 112, new DateTime(2025, 6, 19, 9, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 19, 7, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 19, 7, 58, 0, 0, DateTimeKind.Utc), null, null, 112 },
                    { 113, new DateTime(2025, 6, 27, 19, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 27, 17, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 27, 17, 6, 0, 0, DateTimeKind.Utc), null, null, 113 },
                    { 114, new DateTime(2025, 6, 8, 16, 44, 0, 0, DateTimeKind.Utc), new DateTime(2025, 6, 8, 12, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 6, 8, 12, 59, 0, 0, DateTimeKind.Utc), 3.30m, 44, 114 },
                    { 115, new DateTime(2025, 7, 16, 9, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 16, 9, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 16, 9, 7, 0, 0, DateTimeKind.Utc), null, null, 115 },
                    { 116, new DateTime(2025, 7, 24, 18, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 24, 17, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 24, 17, 59, 0, 0, DateTimeKind.Utc), null, null, 116 },
                    { 117, new DateTime(2025, 7, 4, 17, 44, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 4, 14, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 4, 14, 7, 0, 0, DateTimeKind.Utc), 5.20m, 104, 117 },
                    { 118, new DateTime(2025, 7, 12, 12, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 12, 10, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 12, 10, 0, 0, 0, DateTimeKind.Utc), null, null, 118 },
                    { 119, new DateTime(2025, 7, 20, 21, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 20, 19, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 20, 19, 8, 0, 0, DateTimeKind.Utc), null, null, 119 },
                    { 120, new DateTime(2025, 7, 1, 16, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 1, 15, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 1, 15, 1, 0, 0, DateTimeKind.Utc), 4.35m, 58, 120 },
                    { 121, new DateTime(2025, 7, 9, 13, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 9, 12, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 9, 12, 9, 0, 0, DateTimeKind.Utc), null, null, 121 },
                    { 122, new DateTime(2025, 7, 17, 9, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 17, 8, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 17, 8, 1, 0, 0, DateTimeKind.Utc), null, null, 122 },
                    { 123, new DateTime(2025, 7, 25, 20, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 25, 16, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 25, 16, 9, 0, 0, DateTimeKind.Utc), 7.08m, 118, 123 },
                    { 124, new DateTime(2025, 7, 6, 13, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 6, 13, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 6, 13, 2, 0, 0, DateTimeKind.Utc), null, null, 124 },
                    { 125, new DateTime(2025, 7, 14, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 14, 8, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 14, 8, 55, 0, 0, DateTimeKind.Utc), null, null, 125 },
                    { 126, new DateTime(2025, 7, 22, 21, 12, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 22, 18, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 22, 18, 3, 0, 0, DateTimeKind.Utc), 4.32m, 72, 126 },
                    { 127, new DateTime(2025, 7, 3, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 3, 13, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 3, 13, 56, 0, 0, DateTimeKind.Utc), null, null, 127 },
                    { 128, new DateTime(2025, 7, 11, 12, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 11, 10, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 11, 10, 3, 0, 0, DateTimeKind.Utc), null, null, 128 },
                    { 129, new DateTime(2025, 7, 19, 20, 27, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 19, 18, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 19, 18, 56, 0, 0, DateTimeKind.Utc), 1.35m, 27, 129 },
                    { 130, new DateTime(2025, 7, 26, 15, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 26, 15, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 26, 15, 4, 0, 0, DateTimeKind.Utc), null, null, 130 },
                    { 131, new DateTime(2025, 7, 7, 13, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 7, 11, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 7, 11, 57, 0, 0, DateTimeKind.Utc), null, null, 131 },
                    { 132, new DateTime(2025, 7, 15, 12, 27, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 15, 8, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 15, 8, 5, 0, 0, DateTimeKind.Utc), 4.35m, 87, 132 },
                    { 133, new DateTime(2025, 7, 23, 18, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 23, 15, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 23, 15, 58, 0, 0, DateTimeKind.Utc), null, null, 133 },
                    { 134, new DateTime(2025, 7, 4, 13, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 4, 13, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 4, 13, 5, 0, 0, DateTimeKind.Utc), null, null, 134 },
                    { 135, new DateTime(2025, 7, 12, 11, 41, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 12, 8, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 12, 8, 58, 0, 0, DateTimeKind.Utc), 3.08m, 41, 135 },
                    { 136, new DateTime(2025, 7, 20, 18, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 20, 17, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 20, 17, 6, 0, 0, DateTimeKind.Utc), null, null, 136 },
                    { 137, new DateTime(2025, 7, 1, 16, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 1, 13, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 1, 13, 59, 0, 0, DateTimeKind.Utc), null, null, 137 },
                    { 138, new DateTime(2025, 7, 9, 12, 41, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 9, 10, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 9, 10, 7, 0, 0, DateTimeKind.Utc), 5.05m, 101, 138 },
                    { 139, new DateTime(2025, 7, 17, 19, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 17, 19, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 17, 19, 0, 0, 0, DateTimeKind.Utc), null, null, 139 },
                    { 140, new DateTime(2025, 7, 25, 16, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 7, 25, 15, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 7, 25, 15, 7, 0, 0, DateTimeKind.Utc), null, null, 140 },
                    { 141, new DateTime(2025, 8, 6, 13, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 6, 11, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 6, 11, 0, 0, 0, DateTimeKind.Utc), 4.12m, 55, 141 },
                    { 142, new DateTime(2025, 8, 14, 10, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 14, 8, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 14, 8, 8, 0, 0, DateTimeKind.Utc), null, null, 142 },
                    { 143, new DateTime(2025, 8, 21, 16, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 21, 16, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 21, 16, 1, 0, 0, DateTimeKind.Utc), null, null, 143 },
                    { 144, new DateTime(2025, 8, 2, 15, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 2, 13, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 2, 13, 9, 0, 0, DateTimeKind.Utc), 4.31m, 115, 144 },
                    { 145, new DateTime(2025, 8, 10, 10, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 10, 9, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 10, 9, 2, 0, 0, DateTimeKind.Utc), null, null, 145 },
                    { 146, new DateTime(2025, 8, 18, 20, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 18, 16, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 18, 16, 55, 0, 0, DateTimeKind.Utc), null, null, 146 },
                    { 147, new DateTime(2025, 8, 26, 18, 9, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 26, 14, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 26, 14, 2, 0, 0, DateTimeKind.Utc), 3.45m, 69, 147 },
                    { 148, new DateTime(2025, 8, 7, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 7, 9, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 7, 9, 55, 0, 0, DateTimeKind.Utc), null, null, 148 },
                    { 149, new DateTime(2025, 8, 15, 20, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 15, 19, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 15, 19, 3, 0, 0, DateTimeKind.Utc), null, null, 149 },
                    { 150, new DateTime(2025, 8, 23, 17, 24, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 23, 14, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 23, 14, 56, 0, 0, DateTimeKind.Utc), 1.20m, 24, 150 },
                    { 151, new DateTime(2025, 8, 4, 13, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 4, 11, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 4, 11, 4, 0, 0, DateTimeKind.Utc), null, null, 151 },
                    { 152, new DateTime(2025, 8, 12, 8, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 12, 7, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 12, 7, 57, 0, 0, DateTimeKind.Utc), null, null, 152 },
                    { 153, new DateTime(2025, 8, 20, 18, 24, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 20, 16, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 20, 16, 4, 0, 0, DateTimeKind.Utc), 4.20m, 84, 153 },
                    { 154, new DateTime(2025, 8, 1, 13, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 1, 11, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 1, 11, 57, 0, 0, DateTimeKind.Utc), null, null, 154 },
                    { 155, new DateTime(2025, 8, 9, 10, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 9, 9, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 9, 9, 5, 0, 0, DateTimeKind.Utc), null, null, 155 },
                    { 156, new DateTime(2025, 8, 16, 20, 38, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 16, 16, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 16, 16, 58, 0, 0, DateTimeKind.Utc), 1.90m, 38, 156 },
                    { 157, new DateTime(2025, 8, 24, 14, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 24, 14, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 24, 14, 6, 0, 0, DateTimeKind.Utc), null, null, 157 },
                    { 158, new DateTime(2025, 8, 5, 10, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 5, 9, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 5, 9, 59, 0, 0, DateTimeKind.Utc), null, null, 158 },
                    { 159, new DateTime(2025, 8, 13, 21, 38, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 13, 18, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 13, 18, 6, 0, 0, DateTimeKind.Utc), 4.90m, 98, 159 },
                    { 160, new DateTime(2025, 8, 21, 17, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 21, 14, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 21, 14, 59, 0, 0, DateTimeKind.Utc), null, null, 160 },
                    { 161, new DateTime(2025, 8, 2, 13, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 2, 11, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 2, 11, 7, 0, 0, DateTimeKind.Utc), null, null, 161 },
                    { 162, new DateTime(2025, 8, 10, 9, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 10, 8, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 10, 8, 0, 0, 0, DateTimeKind.Utc), 3.90m, 52, 162 },
                    { 163, new DateTime(2025, 8, 18, 17, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 18, 16, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 18, 16, 8, 0, 0, DateTimeKind.Utc), null, null, 163 },
                    { 164, new DateTime(2025, 8, 26, 13, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 26, 12, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 26, 12, 1, 0, 0, DateTimeKind.Utc), null, null, 164 },
                    { 165, new DateTime(2025, 8, 7, 13, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 7, 9, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 7, 9, 8, 0, 0, DateTimeKind.Utc), 6.72m, 112, 165 },
                    { 166, new DateTime(2025, 8, 15, 19, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 15, 17, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 15, 17, 1, 0, 0, DateTimeKind.Utc), null, null, 166 },
                    { 167, new DateTime(2025, 8, 23, 13, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 23, 13, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 23, 13, 9, 0, 0, DateTimeKind.Utc), null, null, 167 },
                    { 168, new DateTime(2025, 8, 4, 13, 6, 0, 0, DateTimeKind.Utc), new DateTime(2025, 8, 4, 10, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 8, 4, 10, 2, 0, 0, DateTimeKind.Utc), 4.95m, 66, 168 },
                    { 169, new DateTime(2025, 9, 11, 20, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 11, 17, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 11, 17, 55, 0, 0, DateTimeKind.Utc), null, null, 169 },
                    { 170, new DateTime(2025, 9, 19, 17, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 19, 15, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 19, 15, 3, 0, 0, DateTimeKind.Utc), null, null, 170 },
                    { 171, new DateTime(2025, 9, 27, 12, 21, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 27, 10, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 27, 10, 55, 0, 0, DateTimeKind.Utc), 1.05m, 21, 171 },
                    { 172, new DateTime(2025, 9, 8, 19, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 8, 19, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 8, 19, 3, 0, 0, DateTimeKind.Utc), null, null, 172 },
                    { 173, new DateTime(2025, 9, 16, 17, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 16, 15, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 16, 15, 56, 0, 0, DateTimeKind.Utc), null, null, 173 },
                    { 174, new DateTime(2025, 9, 24, 16, 20, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 24, 12, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 24, 12, 4, 0, 0, DateTimeKind.Utc), 4.00m, 80, 174 },
                    { 175, new DateTime(2025, 9, 5, 11, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 5, 8, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 5, 8, 57, 0, 0, DateTimeKind.Utc), null, null, 175 },
                    { 176, new DateTime(2025, 9, 13, 17, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 13, 17, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 13, 17, 5, 0, 0, DateTimeKind.Utc), null, null, 176 },
                    { 177, new DateTime(2025, 9, 21, 15, 35, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 21, 12, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 21, 12, 57, 0, 0, DateTimeKind.Utc), 1.75m, 35, 177 },
                    { 178, new DateTime(2025, 9, 2, 11, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 2, 10, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 2, 10, 5, 0, 0, DateTimeKind.Utc), null, null, 178 },
                    { 179, new DateTime(2025, 9, 10, 20, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 10, 17, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 10, 17, 58, 0, 0, DateTimeKind.Utc), null, null, 179 },
                    { 180, new DateTime(2025, 9, 18, 19, 35, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 18, 15, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 18, 15, 6, 0, 0, DateTimeKind.Utc), 4.75m, 95, 180 },
                    { 181, new DateTime(2025, 9, 26, 11, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 26, 10, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 26, 10, 59, 0, 0, DateTimeKind.Utc), null, null, 181 },
                    { 182, new DateTime(2025, 9, 6, 20, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 6, 19, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 6, 19, 7, 0, 0, DateTimeKind.Utc), null, null, 182 },
                    { 183, new DateTime(2025, 9, 14, 18, 49, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 14, 15, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 14, 15, 59, 0, 0, DateTimeKind.Utc), 3.68m, 49, 183 },
                    { 184, new DateTime(2025, 9, 22, 14, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 22, 12, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 22, 12, 7, 0, 0, DateTimeKind.Utc), null, null, 184 },
                    { 185, new DateTime(2025, 9, 3, 8, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 3, 8, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 3, 8, 0, 0, 0, DateTimeKind.Utc), null, null, 185 },
                    { 186, new DateTime(2025, 9, 11, 19, 49, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 11, 17, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 11, 17, 8, 0, 0, DateTimeKind.Utc), 5.45m, 109, 186 },
                    { 187, new DateTime(2025, 9, 19, 14, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 19, 13, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 19, 13, 1, 0, 0, DateTimeKind.Utc), null, null, 187 },
                    { 188, new DateTime(2025, 9, 27, 12, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 27, 10, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 27, 10, 9, 0, 0, DateTimeKind.Utc), null, null, 188 },
                    { 189, new DateTime(2025, 9, 8, 22, 3, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 8, 18, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 8, 18, 1, 0, 0, DateTimeKind.Utc), 4.72m, 63, 189 },
                    { 190, new DateTime(2025, 9, 16, 14, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 16, 14, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 16, 14, 9, 0, 0, DateTimeKind.Utc), null, null, 190 },
                    { 191, new DateTime(2025, 9, 24, 11, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 24, 11, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 24, 11, 2, 0, 0, DateTimeKind.Utc), null, null, 191 },
                    { 192, new DateTime(2025, 9, 5, 21, 18, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 5, 18, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 5, 18, 55, 0, 0, DateTimeKind.Utc), 0.90m, 18, 192 },
                    { 193, new DateTime(2025, 9, 13, 18, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 13, 16, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 13, 16, 3, 0, 0, DateTimeKind.Utc), null, null, 193 },
                    { 194, new DateTime(2025, 9, 20, 15, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 20, 11, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 20, 11, 56, 0, 0, DateTimeKind.Utc), null, null, 194 },
                    { 195, new DateTime(2025, 9, 1, 10, 17, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 1, 8, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 1, 8, 3, 0, 0, DateTimeKind.Utc), 3.85m, 77, 195 },
                    { 196, new DateTime(2025, 9, 9, 18, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 9, 16, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 9, 16, 56, 0, 0, DateTimeKind.Utc), null, null, 196 },
                    { 197, new DateTime(2025, 9, 17, 14, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 17, 13, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 17, 13, 4, 0, 0, DateTimeKind.Utc), null, null, 197 },
                    { 198, new DateTime(2025, 9, 25, 13, 32, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 25, 9, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 9, 25, 9, 57, 0, 0, DateTimeKind.Utc), 1.60m, 32, 198 },
                    { 199, new DateTime(2025, 10, 6, 18, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 6, 18, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 6, 18, 5, 0, 0, DateTimeKind.Utc), null, null, 199 },
                    { 200, new DateTime(2025, 10, 14, 14, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 14, 13, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 14, 13, 58, 0, 0, DateTimeKind.Utc), null, null, 200 },
                    { 201, new DateTime(2025, 10, 22, 14, 32, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 22, 11, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 22, 11, 6, 0, 0, DateTimeKind.Utc), 5.52m, 92, 201 },
                    { 202, new DateTime(2025, 10, 3, 21, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 3, 18, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 3, 18, 58, 0, 0, DateTimeKind.Utc), null, null, 202 },
                    { 203, new DateTime(2025, 10, 11, 17, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 11, 15, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 11, 15, 6, 0, 0, DateTimeKind.Utc), null, null, 203 },
                    { 204, new DateTime(2025, 10, 19, 13, 46, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 19, 11, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 19, 11, 59, 0, 0, DateTimeKind.Utc), 3.45m, 46, 204 },
                    { 205, new DateTime(2025, 10, 27, 8, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 27, 8, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 27, 8, 7, 0, 0, DateTimeKind.Utc), null, null, 205 },
                    { 206, new DateTime(2025, 10, 8, 18, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 8, 17, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 8, 17, 0, 0, 0, DateTimeKind.Utc), null, null, 206 },
                    { 207, new DateTime(2025, 10, 15, 17, 46, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 15, 13, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 15, 13, 8, 0, 0, DateTimeKind.Utc), 5.30m, 106, 207 },
                    { 208, new DateTime(2025, 10, 23, 11, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 23, 9, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 23, 9, 0, 0, 0, DateTimeKind.Utc), null, null, 208 },
                    { 209, new DateTime(2025, 10, 4, 18, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 4, 18, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 4, 18, 8, 0, 0, DateTimeKind.Utc), null, null, 209 },
                    { 210, new DateTime(2025, 10, 12, 17, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 12, 14, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 12, 14, 1, 0, 0, DateTimeKind.Utc), 4.50m, 60, 210 },
                    { 211, new DateTime(2025, 10, 20, 12, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 20, 11, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 20, 11, 9, 0, 0, DateTimeKind.Utc), null, null, 211 },
                    { 212, new DateTime(2025, 10, 1, 21, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 1, 19, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 1, 19, 2, 0, 0, DateTimeKind.Utc), null, null, 212 },
                    { 213, new DateTime(2025, 10, 9, 16, 15, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 9, 14, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 9, 14, 55, 0, 0, DateTimeKind.Utc), 0.75m, 15, 213 },
                    { 214, new DateTime(2025, 10, 17, 12, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 17, 12, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 17, 12, 2, 0, 0, DateTimeKind.Utc), null, null, 214 },
                    { 215, new DateTime(2025, 10, 25, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 25, 7, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 25, 7, 55, 0, 0, DateTimeKind.Utc), null, null, 215 },
                    { 216, new DateTime(2025, 10, 6, 19, 14, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 6, 16, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 6, 16, 3, 0, 0, DateTimeKind.Utc), 3.70m, 74, 216 },
                    { 217, new DateTime(2025, 10, 14, 16, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 14, 12, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 14, 12, 56, 0, 0, DateTimeKind.Utc), null, null, 217 },
                    { 218, new DateTime(2025, 10, 22, 9, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 22, 9, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 22, 9, 4, 0, 0, DateTimeKind.Utc), null, null, 218 },
                    { 219, new DateTime(2025, 10, 3, 19, 29, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 3, 17, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 3, 17, 57, 0, 0, DateTimeKind.Utc), 1.45m, 29, 219 },
                    { 220, new DateTime(2025, 10, 10, 15, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 10, 14, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 10, 14, 4, 0, 0, DateTimeKind.Utc), null, null, 220 },
                    { 221, new DateTime(2025, 10, 18, 12, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 18, 9, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 18, 9, 57, 0, 0, DateTimeKind.Utc), null, null, 221 },
                    { 222, new DateTime(2025, 10, 26, 23, 28, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 26, 19, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 26, 19, 5, 0, 0, DateTimeKind.Utc), 3.30m, 88, 222 },
                    { 223, new DateTime(2025, 10, 7, 15, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 7, 14, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 7, 14, 58, 0, 0, DateTimeKind.Utc), null, null, 223 },
                    { 224, new DateTime(2025, 10, 15, 13, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 15, 12, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 15, 12, 6, 0, 0, DateTimeKind.Utc), null, null, 224 },
                    { 225, new DateTime(2025, 10, 23, 10, 43, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 23, 7, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 23, 7, 59, 0, 0, DateTimeKind.Utc), 3.22m, 43, 225 },
                    { 226, new DateTime(2025, 10, 4, 18, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 4, 16, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 4, 16, 6, 0, 0, DateTimeKind.Utc), null, null, 226 },
                    { 227, new DateTime(2025, 10, 12, 13, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 12, 12, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 12, 12, 59, 0, 0, DateTimeKind.Utc), null, null, 227 },
                    { 228, new DateTime(2025, 10, 20, 11, 43, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 20, 9, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 20, 9, 7, 0, 0, DateTimeKind.Utc), 5.15m, 103, 228 },
                    { 229, new DateTime(2025, 10, 1, 19, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 1, 18, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 1, 18, 0, 0, 0, DateTimeKind.Utc), null, null, 229 },
                    { 230, new DateTime(2025, 10, 9, 15, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 9, 14, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 10, 9, 14, 8, 0, 0, DateTimeKind.Utc), null, null, 230 },
                    { 231, new DateTime(2025, 11, 17, 13, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 17, 10, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 17, 10, 1, 0, 0, DateTimeKind.Utc), 4.28m, 57, 231 },
                    { 232, new DateTime(2025, 11, 25, 19, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 25, 19, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 25, 19, 8, 0, 0, DateTimeKind.Utc), null, null, 232 },
                    { 233, new DateTime(2025, 11, 5, 15, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 5, 15, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 5, 15, 1, 0, 0, DateTimeKind.Utc), null, null, 233 },
                    { 234, new DateTime(2025, 11, 13, 14, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 13, 11, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 13, 11, 9, 0, 0, DateTimeKind.Utc), 5.85m, 117, 234 },
                    { 235, new DateTime(2025, 11, 21, 10, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 21, 8, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 21, 8, 2, 0, 0, DateTimeKind.Utc), null, null, 235 },
                    { 236, new DateTime(2025, 11, 2, 19, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 2, 15, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 2, 15, 55, 0, 0, DateTimeKind.Utc), null, null, 236 },
                    { 237, new DateTime(2025, 11, 10, 15, 11, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 10, 13, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 10, 13, 3, 0, 0, DateTimeKind.Utc), 3.55m, 71, 237 },
                    { 238, new DateTime(2025, 11, 18, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 18, 8, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 18, 8, 55, 0, 0, DateTimeKind.Utc), null, null, 238 },
                    { 239, new DateTime(2025, 11, 26, 18, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 26, 17, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 26, 17, 3, 0, 0, DateTimeKind.Utc), null, null, 239 },
                    { 240, new DateTime(2025, 11, 7, 17, 26, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 7, 13, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 7, 13, 56, 0, 0, DateTimeKind.Utc), 1.30m, 26, 240 },
                    { 241, new DateTime(2025, 11, 15, 12, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 15, 10, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 15, 10, 4, 0, 0, DateTimeKind.Utc), null, null, 241 },
                    { 242, new DateTime(2025, 11, 23, 19, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 23, 18, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 23, 18, 57, 0, 0, DateTimeKind.Utc), null, null, 242 },
                    { 243, new DateTime(2025, 11, 4, 18, 25, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 4, 15, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 4, 15, 5, 0, 0, DateTimeKind.Utc), 5.10m, 85, 243 },
                    { 244, new DateTime(2025, 11, 12, 12, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 12, 10, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 12, 10, 57, 0, 0, DateTimeKind.Utc), null, null, 244 },
                    { 245, new DateTime(2025, 11, 20, 10, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 20, 8, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 20, 8, 5, 0, 0, DateTimeKind.Utc), null, null, 245 },
                    { 246, new DateTime(2025, 11, 27, 17, 40, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 27, 15, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 27, 15, 58, 0, 0, DateTimeKind.Utc), 2.00m, 40, 246 },
                    { 247, new DateTime(2025, 11, 8, 13, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 8, 13, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 8, 13, 6, 0, 0, DateTimeKind.Utc), null, null, 247 },
                    { 248, new DateTime(2025, 11, 16, 10, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 16, 8, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 16, 8, 59, 0, 0, DateTimeKind.Utc), null, null, 248 },
                    { 249, new DateTime(2025, 11, 24, 21, 40, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 24, 17, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 24, 17, 7, 0, 0, DateTimeKind.Utc), 5.00m, 100, 249 },
                    { 250, new DateTime(2025, 11, 5, 16, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 5, 13, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 5, 13, 59, 0, 0, DateTimeKind.Utc), null, null, 250 },
                    { 251, new DateTime(2025, 11, 13, 10, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 13, 10, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 13, 10, 7, 0, 0, DateTimeKind.Utc), null, null, 251 },
                    { 252, new DateTime(2025, 11, 21, 20, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 21, 18, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 21, 18, 0, 0, 0, DateTimeKind.Utc), 4.05m, 54, 252 },
                    { 253, new DateTime(2025, 11, 2, 16, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 2, 15, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 2, 15, 8, 0, 0, DateTimeKind.Utc), null, null, 253 },
                    { 254, new DateTime(2025, 11, 10, 13, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 10, 11, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 10, 11, 1, 0, 0, DateTimeKind.Utc), null, null, 254 },
                    { 255, new DateTime(2025, 11, 18, 12, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 18, 8, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 18, 8, 9, 0, 0, DateTimeKind.Utc), 5.70m, 114, 255 },
                    { 256, new DateTime(2025, 11, 26, 16, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 26, 16, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 26, 16, 2, 0, 0, DateTimeKind.Utc), null, null, 256 },
                    { 257, new DateTime(2025, 11, 7, 13, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 7, 12, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 7, 12, 9, 0, 0, DateTimeKind.Utc), null, null, 257 },
                    { 258, new DateTime(2025, 11, 15, 12, 8, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 15, 9, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 15, 9, 2, 0, 0, DateTimeKind.Utc), 3.40m, 68, 258 },
                    { 259, new DateTime(2025, 11, 22, 20, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 22, 16, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 22, 16, 55, 0, 0, DateTimeKind.Utc), null, null, 259 },
                    { 260, new DateTime(2025, 11, 3, 14, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 3, 14, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 3, 14, 3, 0, 0, DateTimeKind.Utc), null, null, 260 },
                    { 261, new DateTime(2025, 11, 11, 11, 23, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 11, 9, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 11, 9, 56, 0, 0, DateTimeKind.Utc), 0.86m, 23, 261 },
                    { 262, new DateTime(2025, 11, 19, 19, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 19, 18, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 19, 18, 4, 0, 0, DateTimeKind.Utc), null, null, 262 },
                    { 263, new DateTime(2025, 11, 27, 17, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 27, 14, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 27, 14, 56, 0, 0, DateTimeKind.Utc), null, null, 263 },
                    { 264, new DateTime(2025, 11, 8, 15, 22, 0, 0, DateTimeKind.Utc), new DateTime(2025, 11, 8, 11, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 11, 8, 11, 4, 0, 0, DateTimeKind.Utc), 4.10m, 82, 264 },
                    { 265, new DateTime(2025, 12, 16, 19, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 16, 18, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 16, 18, 57, 0, 0, DateTimeKind.Utc), null, null, 265 },
                    { 266, new DateTime(2025, 12, 24, 17, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 24, 16, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 24, 16, 5, 0, 0, DateTimeKind.Utc), null, null, 266 },
                    { 267, new DateTime(2025, 12, 5, 14, 37, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 5, 11, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 5, 11, 58, 0, 0, DateTimeKind.Utc), 1.85m, 37, 267 },
                    { 268, new DateTime(2025, 12, 13, 11, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 13, 9, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 13, 9, 6, 0, 0, DateTimeKind.Utc), null, null, 268 },
                    { 269, new DateTime(2025, 12, 21, 19, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 21, 16, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 21, 16, 58, 0, 0, DateTimeKind.Utc), null, null, 269 },
                    { 270, new DateTime(2025, 12, 2, 15, 37, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 2, 13, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 2, 13, 6, 0, 0, DateTimeKind.Utc), 4.85m, 97, 270 },
                    { 271, new DateTime(2025, 12, 10, 11, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 10, 9, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 10, 9, 59, 0, 0, DateTimeKind.Utc), null, null, 271 },
                    { 272, new DateTime(2025, 12, 17, 19, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 17, 18, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 17, 18, 7, 0, 0, DateTimeKind.Utc), null, null, 272 },
                    { 273, new DateTime(2025, 12, 25, 18, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 25, 15, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 25, 15, 0, 0, 0, DateTimeKind.Utc), 3.82m, 51, 273 },
                    { 274, new DateTime(2025, 12, 6, 11, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 6, 11, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 6, 11, 8, 0, 0, DateTimeKind.Utc), null, null, 274 },
                    { 275, new DateTime(2025, 12, 14, 19, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 14, 19, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 14, 19, 0, 0, 0, DateTimeKind.Utc), null, null, 275 },
                    { 276, new DateTime(2025, 12, 22, 19, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 22, 16, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 22, 16, 8, 0, 0, DateTimeKind.Utc), 5.55m, 111, 276 },
                    { 277, new DateTime(2025, 12, 3, 14, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 3, 12, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 3, 12, 1, 0, 0, DateTimeKind.Utc), null, null, 277 },
                    { 278, new DateTime(2025, 12, 11, 11, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 11, 9, 9, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 11, 9, 9, 0, 0, DateTimeKind.Utc), null, null, 278 },
                    { 279, new DateTime(2025, 12, 19, 19, 5, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 19, 17, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 19, 17, 2, 0, 0, DateTimeKind.Utc), 4.88m, 65, 279 },
                    { 280, new DateTime(2025, 12, 27, 14, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 27, 12, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 27, 12, 55, 0, 0, DateTimeKind.Utc), null, null, 280 },
                    { 281, new DateTime(2025, 12, 8, 11, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 8, 10, 2, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 8, 10, 2, 0, 0, DateTimeKind.Utc), null, null, 281 },
                    { 282, new DateTime(2025, 12, 16, 21, 20, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 16, 17, 55, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 16, 17, 55, 0, 0, DateTimeKind.Utc), 1.20m, 20, 282 },
                    { 283, new DateTime(2025, 12, 24, 16, 55, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 24, 14, 3, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 24, 14, 3, 0, 0, DateTimeKind.Utc), null, null, 283 },
                    { 284, new DateTime(2025, 12, 5, 12, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 5, 10, 56, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 5, 10, 56, 0, 0, DateTimeKind.Utc), null, null, 284 },
                    { 285, new DateTime(2025, 12, 12, 22, 19, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 12, 19, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 12, 19, 4, 0, 0, DateTimeKind.Utc), 3.95m, 79, 285 },
                    { 286, new DateTime(2025, 12, 20, 17, 59, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 20, 15, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 20, 15, 57, 0, 0, DateTimeKind.Utc), null, null, 286 },
                    { 287, new DateTime(2025, 12, 1, 14, 54, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 1, 12, 4, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 1, 12, 4, 0, 0, DateTimeKind.Utc), null, null, 287 },
                    { 288, new DateTime(2025, 12, 9, 9, 34, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 9, 7, 57, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 9, 7, 57, 0, 0, DateTimeKind.Utc), 1.70m, 34, 288 },
                    { 289, new DateTime(2025, 12, 17, 17, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 17, 17, 5, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 17, 17, 5, 0, 0, DateTimeKind.Utc), null, null, 289 },
                    { 290, new DateTime(2025, 12, 25, 14, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 25, 12, 58, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 25, 12, 58, 0, 0, DateTimeKind.Utc), null, null, 290 },
                    { 291, new DateTime(2025, 12, 6, 14, 33, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 6, 10, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 6, 10, 6, 0, 0, DateTimeKind.Utc), 4.65m, 93, 291 },
                    { 292, new DateTime(2025, 12, 14, 20, 58, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 14, 17, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 14, 17, 59, 0, 0, DateTimeKind.Utc), null, null, 292 },
                    { 293, new DateTime(2025, 12, 22, 14, 53, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 22, 14, 6, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 22, 14, 6, 0, 0, DateTimeKind.Utc), null, null, 293 },
                    { 294, new DateTime(2025, 12, 3, 12, 48, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 3, 10, 59, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 3, 10, 59, 0, 0, DateTimeKind.Utc), 3.60m, 48, 294 },
                    { 295, new DateTime(2025, 12, 11, 20, 52, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 11, 19, 7, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 11, 19, 7, 0, 0, DateTimeKind.Utc), null, null, 295 },
                    { 296, new DateTime(2025, 12, 19, 18, 57, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 19, 16, 0, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 19, 16, 0, 0, 0, DateTimeKind.Utc), null, null, 296 },
                    { 297, new DateTime(2025, 12, 26, 16, 48, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 26, 12, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 26, 12, 8, 0, 0, DateTimeKind.Utc), 5.40m, 108, 297 },
                    { 298, new DateTime(2025, 12, 7, 8, 56, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 7, 8, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 7, 8, 1, 0, 0, DateTimeKind.Utc), null, null, 298 },
                    { 299, new DateTime(2025, 12, 15, 18, 51, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 15, 17, 8, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 15, 17, 8, 0, 0, DateTimeKind.Utc), null, null, 299 },
                    { 300, new DateTime(2025, 12, 23, 16, 2, 0, 0, DateTimeKind.Utc), new DateTime(2025, 12, 23, 13, 1, 0, 0, DateTimeKind.Utc), null, new DateTime(2025, 12, 23, 13, 1, 0, 0, DateTimeKind.Utc), 4.65m, 62, 300 }
                });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "Id", "Comment", "CreatedAt", "Rating", "ReservationId", "UserId" },
                values: new object[,]
                {
                    { 1, "Excellent service, easy to find the spot.", new DateTime(2025, 1, 3, 16, 30, 0, 0, DateTimeKind.Utc), 4, 1, 1 },
                    { 2, "Smooth parking process, highly recommended!", new DateTime(2025, 1, 11, 12, 30, 0, 0, DateTimeKind.Utc), 5, 2, 2 },
                    { 3, "Top notch facility, will use again.", new DateTime(2025, 1, 19, 19, 30, 0, 0, DateTimeKind.Utc), 4, 3, 3 },
                    { 4, "Simple and fast, exactly what I needed.", new DateTime(2025, 1, 27, 16, 30, 0, 0, DateTimeKind.Utc), 5, 4, 4 },
                    { 5, "Great experience, very convenient!", new DateTime(2025, 1, 8, 13, 30, 0, 0, DateTimeKind.Utc), 4, 5, 5 },
                    { 6, "Excellent service, easy to find the spot.", new DateTime(2025, 1, 16, 22, 30, 0, 0, DateTimeKind.Utc), 5, 6, 6 },
                    { 7, "Smooth parking process, highly recommended!", new DateTime(2025, 1, 24, 16, 30, 0, 0, DateTimeKind.Utc), 4, 7, 7 },
                    { 8, "Top notch facility, will use again.", new DateTime(2025, 1, 5, 13, 30, 0, 0, DateTimeKind.Utc), 5, 8, 8 },
                    { 9, "Simple and fast, exactly what I needed.", new DateTime(2025, 1, 13, 10, 30, 0, 0, DateTimeKind.Utc), 4, 9, 9 },
                    { 10, "Great experience, very convenient!", new DateTime(2025, 1, 21, 20, 30, 0, 0, DateTimeKind.Utc), 5, 10, 10 },
                    { 11, "Excellent service, easy to find the spot.", new DateTime(2025, 1, 2, 16, 30, 0, 0, DateTimeKind.Utc), 4, 11, 11 },
                    { 12, "Smooth parking process, highly recommended!", new DateTime(2025, 1, 10, 10, 30, 0, 0, DateTimeKind.Utc), 5, 12, 12 },
                    { 13, "Top notch facility, will use again.", new DateTime(2025, 1, 18, 19, 30, 0, 0, DateTimeKind.Utc), 4, 13, 1 },
                    { 14, "Simple and fast, exactly what I needed.", new DateTime(2025, 1, 25, 16, 30, 0, 0, DateTimeKind.Utc), 5, 14, 2 },
                    { 15, "Great experience, very convenient!", new DateTime(2025, 2, 6, 14, 30, 0, 0, DateTimeKind.Utc), 4, 15, 1 },
                    { 16, "Excellent service, easy to find the spot.", new DateTime(2025, 2, 14, 22, 30, 0, 0, DateTimeKind.Utc), 5, 16, 2 },
                    { 17, "Smooth parking process, highly recommended!", new DateTime(2025, 2, 22, 16, 30, 0, 0, DateTimeKind.Utc), 4, 17, 3 },
                    { 18, "Top notch facility, will use again.", new DateTime(2025, 2, 3, 14, 30, 0, 0, DateTimeKind.Utc), 5, 18, 4 },
                    { 19, "Simple and fast, exactly what I needed.", new DateTime(2025, 2, 11, 10, 30, 0, 0, DateTimeKind.Utc), 4, 19, 5 },
                    { 20, "Great experience, very convenient!", new DateTime(2025, 2, 19, 19, 30, 0, 0, DateTimeKind.Utc), 5, 20, 6 },
                    { 21, "Excellent service, easy to find the spot.", new DateTime(2025, 2, 27, 14, 30, 0, 0, DateTimeKind.Utc), 4, 21, 7 },
                    { 22, "Smooth parking process, highly recommended!", new DateTime(2025, 2, 8, 10, 30, 0, 0, DateTimeKind.Utc), 5, 22, 8 },
                    { 23, "Top notch facility, will use again.", new DateTime(2025, 2, 16, 20, 30, 0, 0, DateTimeKind.Utc), 4, 23, 9 },
                    { 24, "Simple and fast, exactly what I needed.", new DateTime(2025, 2, 24, 17, 30, 0, 0, DateTimeKind.Utc), 5, 24, 10 },
                    { 25, "Great experience, very convenient!", new DateTime(2025, 2, 5, 13, 30, 0, 0, DateTimeKind.Utc), 4, 25, 11 },
                    { 26, "Excellent service, easy to find the spot.", new DateTime(2025, 2, 13, 20, 30, 0, 0, DateTimeKind.Utc), 5, 26, 12 },
                    { 27, "Smooth parking process, highly recommended!", new DateTime(2025, 2, 20, 16, 30, 0, 0, DateTimeKind.Utc), 4, 27, 1 },
                    { 28, "Top notch facility, will use again.", new DateTime(2025, 2, 1, 14, 30, 0, 0, DateTimeKind.Utc), 5, 28, 2 },
                    { 29, "Simple and fast, exactly what I needed.", new DateTime(2025, 2, 9, 11, 30, 0, 0, DateTimeKind.Utc), 4, 29, 3 },
                    { 30, "Great experience, very convenient!", new DateTime(2025, 2, 17, 19, 30, 0, 0, DateTimeKind.Utc), 5, 30, 4 },
                    { 31, "Excellent service, easy to find the spot.", new DateTime(2025, 3, 25, 14, 30, 0, 0, DateTimeKind.Utc), 4, 31, 1 },
                    { 32, "Smooth parking process, highly recommended!", new DateTime(2025, 3, 6, 11, 30, 0, 0, DateTimeKind.Utc), 5, 32, 2 },
                    { 33, "Top notch facility, will use again.", new DateTime(2025, 3, 14, 20, 30, 0, 0, DateTimeKind.Utc), 4, 33, 3 },
                    { 34, "Simple and fast, exactly what I needed.", new DateTime(2025, 3, 22, 17, 30, 0, 0, DateTimeKind.Utc), 5, 34, 4 },
                    { 35, "Great experience, very convenient!", new DateTime(2025, 3, 3, 11, 30, 0, 0, DateTimeKind.Utc), 4, 35, 5 },
                    { 36, "Excellent service, easy to find the spot.", new DateTime(2025, 3, 11, 20, 30, 0, 0, DateTimeKind.Utc), 5, 36, 6 },
                    { 37, "Smooth parking process, highly recommended!", new DateTime(2025, 3, 19, 17, 30, 0, 0, DateTimeKind.Utc), 4, 37, 7 },
                    { 38, "Top notch facility, will use again.", new DateTime(2025, 3, 27, 14, 30, 0, 0, DateTimeKind.Utc), 5, 38, 8 },
                    { 39, "Simple and fast, exactly what I needed.", new DateTime(2025, 3, 8, 11, 30, 0, 0, DateTimeKind.Utc), 4, 39, 9 },
                    { 40, "Great experience, very convenient!", new DateTime(2025, 3, 15, 17, 30, 0, 0, DateTimeKind.Utc), 5, 40, 10 },
                    { 41, "Excellent service, easy to find the spot.", new DateTime(2025, 3, 23, 14, 30, 0, 0, DateTimeKind.Utc), 4, 41, 11 },
                    { 42, "Smooth parking process, highly recommended!", new DateTime(2025, 3, 4, 11, 30, 0, 0, DateTimeKind.Utc), 5, 42, 12 },
                    { 43, "Top notch facility, will use again.", new DateTime(2025, 3, 12, 20, 30, 0, 0, DateTimeKind.Utc), 4, 43, 1 },
                    { 44, "Simple and fast, exactly what I needed.", new DateTime(2025, 3, 20, 17, 30, 0, 0, DateTimeKind.Utc), 5, 44, 2 },
                    { 45, "Great experience, very convenient!", new DateTime(2025, 3, 1, 11, 30, 0, 0, DateTimeKind.Utc), 4, 45, 3 },
                    { 46, "Excellent service, easy to find the spot.", new DateTime(2025, 3, 9, 21, 30, 0, 0, DateTimeKind.Utc), 5, 46, 4 },
                    { 47, "Smooth parking process, highly recommended!", new DateTime(2025, 3, 17, 17, 30, 0, 0, DateTimeKind.Utc), 4, 47, 5 },
                    { 48, "Top notch facility, will use again.", new DateTime(2025, 3, 25, 14, 30, 0, 0, DateTimeKind.Utc), 5, 48, 6 },
                    { 49, "Simple and fast, exactly what I needed.", new DateTime(2025, 4, 6, 9, 30, 0, 0, DateTimeKind.Utc), 4, 49, 1 },
                    { 50, "Great experience, very convenient!", new DateTime(2025, 4, 14, 17, 30, 0, 0, DateTimeKind.Utc), 5, 50, 2 },
                    { 51, "Excellent service, easy to find the spot.", new DateTime(2025, 4, 22, 14, 30, 0, 0, DateTimeKind.Utc), 4, 51, 3 },
                    { 52, "Smooth parking process, highly recommended!", new DateTime(2025, 4, 3, 11, 30, 0, 0, DateTimeKind.Utc), 5, 52, 4 },
                    { 53, "Top notch facility, will use again.", new DateTime(2025, 4, 10, 20, 30, 0, 0, DateTimeKind.Utc), 4, 53, 5 },
                    { 54, "Simple and fast, exactly what I needed.", new DateTime(2025, 4, 18, 15, 30, 0, 0, DateTimeKind.Utc), 5, 54, 6 },
                    { 55, "Great experience, very convenient!", new DateTime(2025, 4, 26, 11, 30, 0, 0, DateTimeKind.Utc), 4, 55, 7 },
                    { 56, "Excellent service, easy to find the spot.", new DateTime(2025, 4, 7, 20, 30, 0, 0, DateTimeKind.Utc), 5, 56, 8 },
                    { 57, "Smooth parking process, highly recommended!", new DateTime(2025, 4, 15, 18, 30, 0, 0, DateTimeKind.Utc), 4, 57, 9 },
                    { 58, "Top notch facility, will use again.", new DateTime(2025, 4, 23, 14, 30, 0, 0, DateTimeKind.Utc), 5, 58, 10 },
                    { 59, "Simple and fast, exactly what I needed.", new DateTime(2025, 4, 4, 9, 30, 0, 0, DateTimeKind.Utc), 4, 59, 11 },
                    { 60, "Great experience, very convenient!", new DateTime(2025, 4, 12, 18, 30, 0, 0, DateTimeKind.Utc), 5, 60, 12 },
                    { 61, "Excellent service, easy to find the spot.", new DateTime(2025, 4, 20, 14, 30, 0, 0, DateTimeKind.Utc), 4, 61, 1 },
                    { 62, "Smooth parking process, highly recommended!", new DateTime(2025, 4, 1, 12, 30, 0, 0, DateTimeKind.Utc), 5, 62, 2 },
                    { 63, "Top notch facility, will use again.", new DateTime(2025, 4, 9, 18, 30, 0, 0, DateTimeKind.Utc), 4, 63, 3 },
                    { 64, "Simple and fast, exactly what I needed.", new DateTime(2025, 4, 17, 15, 30, 0, 0, DateTimeKind.Utc), 5, 64, 4 },
                    { 65, "Great experience, very convenient!", new DateTime(2025, 4, 25, 12, 30, 0, 0, DateTimeKind.Utc), 4, 65, 5 },
                    { 66, "Excellent service, easy to find the spot.", new DateTime(2025, 4, 5, 20, 30, 0, 0, DateTimeKind.Utc), 5, 66, 6 },
                    { 67, "Smooth parking process, highly recommended!", new DateTime(2025, 4, 13, 18, 30, 0, 0, DateTimeKind.Utc), 4, 67, 7 },
                    { 68, "Top notch facility, will use again.", new DateTime(2025, 4, 21, 12, 30, 0, 0, DateTimeKind.Utc), 5, 68, 8 },
                    { 69, "Simple and fast, exactly what I needed.", new DateTime(2025, 5, 2, 20, 30, 0, 0, DateTimeKind.Utc), 4, 69, 1 },
                    { 70, "Great experience, very convenient!", new DateTime(2025, 5, 10, 18, 30, 0, 0, DateTimeKind.Utc), 5, 70, 2 },
                    { 71, "Excellent service, easy to find the spot.", new DateTime(2025, 5, 18, 15, 30, 0, 0, DateTimeKind.Utc), 4, 71, 3 },
                    { 72, "Smooth parking process, highly recommended!", new DateTime(2025, 5, 26, 12, 30, 0, 0, DateTimeKind.Utc), 5, 72, 4 },
                    { 73, "Top notch facility, will use again.", new DateTime(2025, 5, 7, 18, 30, 0, 0, DateTimeKind.Utc), 4, 73, 5 },
                    { 74, "Simple and fast, exactly what I needed.", new DateTime(2025, 5, 15, 15, 30, 0, 0, DateTimeKind.Utc), 5, 74, 6 },
                    { 75, "Great experience, very convenient!", new DateTime(2025, 5, 23, 12, 30, 0, 0, DateTimeKind.Utc), 4, 75, 7 },
                    { 76, "Excellent service, easy to find the spot.", new DateTime(2025, 5, 4, 21, 30, 0, 0, DateTimeKind.Utc), 5, 76, 8 },
                    { 77, "Smooth parking process, highly recommended!", new DateTime(2025, 5, 12, 18, 30, 0, 0, DateTimeKind.Utc), 4, 77, 9 },
                    { 78, "Top notch facility, will use again.", new DateTime(2025, 5, 20, 12, 30, 0, 0, DateTimeKind.Utc), 5, 78, 10 },
                    { 79, "Simple and fast, exactly what I needed.", new DateTime(2025, 5, 27, 21, 30, 0, 0, DateTimeKind.Utc), 4, 79, 11 },
                    { 80, "Great experience, very convenient!", new DateTime(2025, 5, 8, 18, 30, 0, 0, DateTimeKind.Utc), 5, 80, 12 },
                    { 81, "Excellent service, easy to find the spot.", new DateTime(2025, 5, 16, 15, 30, 0, 0, DateTimeKind.Utc), 4, 81, 1 },
                    { 82, "Smooth parking process, highly recommended!", new DateTime(2025, 5, 24, 10, 30, 0, 0, DateTimeKind.Utc), 5, 82, 2 },
                    { 83, "Top notch facility, will use again.", new DateTime(2025, 5, 5, 18, 30, 0, 0, DateTimeKind.Utc), 4, 83, 3 },
                    { 84, "Simple and fast, exactly what I needed.", new DateTime(2025, 5, 13, 15, 30, 0, 0, DateTimeKind.Utc), 5, 84, 4 },
                    { 85, "Great experience, very convenient!", new DateTime(2025, 5, 21, 13, 30, 0, 0, DateTimeKind.Utc), 4, 85, 5 },
                    { 86, "Excellent service, easy to find the spot.", new DateTime(2025, 5, 2, 21, 30, 0, 0, DateTimeKind.Utc), 5, 86, 6 },
                    { 87, "Smooth parking process, highly recommended!", new DateTime(2025, 5, 10, 15, 30, 0, 0, DateTimeKind.Utc), 4, 87, 7 },
                    { 88, "Top notch facility, will use again.", new DateTime(2025, 5, 18, 13, 30, 0, 0, DateTimeKind.Utc), 5, 88, 8 },
                    { 89, "Simple and fast, exactly what I needed.", new DateTime(2025, 5, 26, 21, 30, 0, 0, DateTimeKind.Utc), 4, 89, 9 },
                    { 90, "Great experience, very convenient!", new DateTime(2025, 5, 7, 19, 30, 0, 0, DateTimeKind.Utc), 5, 90, 10 },
                    { 91, "Excellent service, easy to find the spot.", new DateTime(2025, 6, 14, 15, 30, 0, 0, DateTimeKind.Utc), 4, 91, 1 },
                    { 92, "Smooth parking process, highly recommended!", new DateTime(2025, 6, 22, 9, 30, 0, 0, DateTimeKind.Utc), 5, 92, 2 },
                    { 93, "Top notch facility, will use again.", new DateTime(2025, 6, 3, 19, 30, 0, 0, DateTimeKind.Utc), 4, 93, 3 },
                    { 94, "Simple and fast, exactly what I needed.", new DateTime(2025, 6, 11, 15, 30, 0, 0, DateTimeKind.Utc), 5, 94, 4 },
                    { 95, "Great experience, very convenient!", new DateTime(2025, 6, 19, 13, 30, 0, 0, DateTimeKind.Utc), 4, 95, 5 },
                    { 96, "Excellent service, easy to find the spot.", new DateTime(2025, 6, 27, 19, 30, 0, 0, DateTimeKind.Utc), 5, 96, 6 },
                    { 97, "Smooth parking process, highly recommended!", new DateTime(2025, 6, 8, 15, 30, 0, 0, DateTimeKind.Utc), 4, 97, 7 },
                    { 98, "Top notch facility, will use again.", new DateTime(2025, 6, 16, 13, 30, 0, 0, DateTimeKind.Utc), 5, 98, 8 },
                    { 99, "Simple and fast, exactly what I needed.", new DateTime(2025, 6, 24, 22, 30, 0, 0, DateTimeKind.Utc), 4, 99, 9 },
                    { 100, "Great experience, very convenient!", new DateTime(2025, 6, 5, 19, 30, 0, 0, DateTimeKind.Utc), 5, 100, 10 },
                    { 101, "Excellent service, easy to find the spot.", new DateTime(2025, 6, 13, 13, 30, 0, 0, DateTimeKind.Utc), 4, 101, 11 },
                    { 102, "Smooth parking process, highly recommended!", new DateTime(2025, 6, 21, 9, 30, 0, 0, DateTimeKind.Utc), 5, 102, 12 },
                    { 103, "Top notch facility, will use again.", new DateTime(2025, 6, 2, 19, 30, 0, 0, DateTimeKind.Utc), 4, 103, 1 },
                    { 104, "Simple and fast, exactly what I needed.", new DateTime(2025, 6, 9, 16, 30, 0, 0, DateTimeKind.Utc), 5, 104, 2 },
                    { 105, "Great experience, very convenient!", new DateTime(2025, 6, 17, 12, 30, 0, 0, DateTimeKind.Utc), 4, 105, 3 },
                    { 106, "Excellent service, easy to find the spot.", new DateTime(2025, 6, 25, 19, 30, 0, 0, DateTimeKind.Utc), 5, 106, 4 },
                    { 107, "Smooth parking process, highly recommended!", new DateTime(2025, 6, 6, 16, 30, 0, 0, DateTimeKind.Utc), 4, 107, 5 },
                    { 108, "Top notch facility, will use again.", new DateTime(2025, 6, 14, 13, 30, 0, 0, DateTimeKind.Utc), 5, 108, 6 },
                    { 109, "Simple and fast, exactly what I needed.", new DateTime(2025, 6, 22, 22, 30, 0, 0, DateTimeKind.Utc), 4, 109, 7 },
                    { 110, "Great experience, very convenient!", new DateTime(2025, 6, 3, 16, 30, 0, 0, DateTimeKind.Utc), 5, 110, 8 },
                    { 111, "Excellent service, easy to find the spot.", new DateTime(2025, 6, 11, 13, 30, 0, 0, DateTimeKind.Utc), 4, 111, 9 },
                    { 112, "Smooth parking process, highly recommended!", new DateTime(2025, 6, 19, 10, 30, 0, 0, DateTimeKind.Utc), 5, 112, 10 },
                    { 113, "Top notch facility, will use again.", new DateTime(2025, 6, 27, 20, 30, 0, 0, DateTimeKind.Utc), 4, 113, 11 },
                    { 114, "Simple and fast, exactly what I needed.", new DateTime(2025, 6, 8, 16, 30, 0, 0, DateTimeKind.Utc), 5, 114, 12 },
                    { 115, "Great experience, very convenient!", new DateTime(2025, 7, 16, 10, 30, 0, 0, DateTimeKind.Utc), 4, 115, 1 },
                    { 116, "Excellent service, easy to find the spot.", new DateTime(2025, 7, 24, 19, 30, 0, 0, DateTimeKind.Utc), 5, 116, 2 },
                    { 117, "Smooth parking process, highly recommended!", new DateTime(2025, 7, 4, 16, 30, 0, 0, DateTimeKind.Utc), 4, 117, 3 },
                    { 118, "Top notch facility, will use again.", new DateTime(2025, 7, 12, 13, 30, 0, 0, DateTimeKind.Utc), 5, 118, 4 },
                    { 119, "Simple and fast, exactly what I needed.", new DateTime(2025, 7, 20, 22, 30, 0, 0, DateTimeKind.Utc), 4, 119, 5 },
                    { 120, "Great experience, very convenient!", new DateTime(2025, 7, 1, 16, 30, 0, 0, DateTimeKind.Utc), 5, 120, 6 },
                    { 121, "Excellent service, easy to find the spot.", new DateTime(2025, 7, 9, 14, 30, 0, 0, DateTimeKind.Utc), 4, 121, 7 },
                    { 122, "Smooth parking process, highly recommended!", new DateTime(2025, 7, 17, 10, 30, 0, 0, DateTimeKind.Utc), 5, 122, 8 },
                    { 123, "Top notch facility, will use again.", new DateTime(2025, 7, 25, 19, 30, 0, 0, DateTimeKind.Utc), 4, 123, 9 },
                    { 124, "Simple and fast, exactly what I needed.", new DateTime(2025, 7, 6, 14, 30, 0, 0, DateTimeKind.Utc), 5, 124, 10 },
                    { 125, "Great experience, very convenient!", new DateTime(2025, 7, 14, 10, 30, 0, 0, DateTimeKind.Utc), 4, 125, 11 },
                    { 126, "Excellent service, easy to find the spot.", new DateTime(2025, 7, 22, 20, 30, 0, 0, DateTimeKind.Utc), 5, 126, 12 },
                    { 127, "Smooth parking process, highly recommended!", new DateTime(2025, 7, 3, 16, 30, 0, 0, DateTimeKind.Utc), 4, 127, 1 },
                    { 128, "Top notch facility, will use again.", new DateTime(2025, 7, 11, 13, 30, 0, 0, DateTimeKind.Utc), 5, 128, 2 },
                    { 129, "Simple and fast, exactly what I needed.", new DateTime(2025, 7, 19, 20, 30, 0, 0, DateTimeKind.Utc), 4, 129, 3 },
                    { 130, "Great experience, very convenient!", new DateTime(2025, 7, 26, 16, 30, 0, 0, DateTimeKind.Utc), 5, 130, 4 },
                    { 131, "Excellent service, easy to find the spot.", new DateTime(2025, 7, 7, 14, 30, 0, 0, DateTimeKind.Utc), 4, 131, 5 },
                    { 132, "Smooth parking process, highly recommended!", new DateTime(2025, 7, 15, 11, 30, 0, 0, DateTimeKind.Utc), 5, 132, 6 },
                    { 133, "Top notch facility, will use again.", new DateTime(2025, 7, 23, 19, 30, 0, 0, DateTimeKind.Utc), 4, 133, 7 },
                    { 134, "Simple and fast, exactly what I needed.", new DateTime(2025, 7, 4, 14, 30, 0, 0, DateTimeKind.Utc), 5, 134, 8 },
                    { 135, "Great experience, very convenient!", new DateTime(2025, 7, 12, 11, 30, 0, 0, DateTimeKind.Utc), 4, 135, 9 },
                    { 136, "Excellent service, easy to find the spot.", new DateTime(2025, 7, 20, 19, 30, 0, 0, DateTimeKind.Utc), 5, 136, 10 },
                    { 137, "Smooth parking process, highly recommended!", new DateTime(2025, 7, 1, 17, 30, 0, 0, DateTimeKind.Utc), 4, 137, 11 },
                    { 138, "Top notch facility, will use again.", new DateTime(2025, 7, 9, 11, 30, 0, 0, DateTimeKind.Utc), 5, 138, 12 },
                    { 139, "Simple and fast, exactly what I needed.", new DateTime(2025, 7, 17, 20, 30, 0, 0, DateTimeKind.Utc), 4, 139, 1 },
                    { 140, "Great experience, very convenient!", new DateTime(2025, 7, 25, 17, 30, 0, 0, DateTimeKind.Utc), 5, 140, 2 },
                    { 141, "Excellent service, easy to find the spot.", new DateTime(2025, 8, 6, 13, 30, 0, 0, DateTimeKind.Utc), 4, 141, 1 },
                    { 142, "Smooth parking process, highly recommended!", new DateTime(2025, 8, 14, 11, 30, 0, 0, DateTimeKind.Utc), 5, 142, 2 },
                    { 143, "Top notch facility, will use again.", new DateTime(2025, 8, 21, 17, 30, 0, 0, DateTimeKind.Utc), 4, 143, 3 },
                    { 144, "Simple and fast, exactly what I needed.", new DateTime(2025, 8, 2, 14, 30, 0, 0, DateTimeKind.Utc), 5, 144, 4 },
                    { 145, "Great experience, very convenient!", new DateTime(2025, 8, 10, 11, 30, 0, 0, DateTimeKind.Utc), 4, 145, 5 },
                    { 146, "Excellent service, easy to find the spot.", new DateTime(2025, 8, 18, 20, 30, 0, 0, DateTimeKind.Utc), 5, 146, 6 },
                    { 147, "Smooth parking process, highly recommended!", new DateTime(2025, 8, 26, 17, 30, 0, 0, DateTimeKind.Utc), 4, 147, 7 },
                    { 148, "Top notch facility, will use again.", new DateTime(2025, 8, 7, 11, 30, 0, 0, DateTimeKind.Utc), 5, 148, 8 },
                    { 149, "Simple and fast, exactly what I needed.", new DateTime(2025, 8, 15, 21, 30, 0, 0, DateTimeKind.Utc), 4, 149, 9 },
                    { 150, "Great experience, very convenient!", new DateTime(2025, 8, 23, 17, 30, 0, 0, DateTimeKind.Utc), 5, 150, 10 },
                    { 151, "Excellent service, easy to find the spot.", new DateTime(2025, 8, 4, 14, 30, 0, 0, DateTimeKind.Utc), 4, 151, 11 },
                    { 152, "Smooth parking process, highly recommended!", new DateTime(2025, 8, 12, 9, 30, 0, 0, DateTimeKind.Utc), 5, 152, 12 },
                    { 153, "Top notch facility, will use again.", new DateTime(2025, 8, 20, 17, 30, 0, 0, DateTimeKind.Utc), 4, 153, 1 },
                    { 154, "Simple and fast, exactly what I needed.", new DateTime(2025, 8, 1, 14, 30, 0, 0, DateTimeKind.Utc), 5, 154, 2 },
                    { 155, "Great experience, very convenient!", new DateTime(2025, 8, 9, 11, 30, 0, 0, DateTimeKind.Utc), 4, 155, 3 },
                    { 156, "Excellent service, easy to find the spot.", new DateTime(2025, 8, 16, 20, 30, 0, 0, DateTimeKind.Utc), 5, 156, 4 },
                    { 157, "Smooth parking process, highly recommended!", new DateTime(2025, 8, 24, 15, 30, 0, 0, DateTimeKind.Utc), 4, 157, 5 },
                    { 158, "Top notch facility, will use again.", new DateTime(2025, 8, 5, 11, 30, 0, 0, DateTimeKind.Utc), 5, 158, 6 },
                    { 159, "Simple and fast, exactly what I needed.", new DateTime(2025, 8, 13, 20, 30, 0, 0, DateTimeKind.Utc), 4, 159, 7 },
                    { 160, "Great experience, very convenient!", new DateTime(2025, 8, 21, 18, 30, 0, 0, DateTimeKind.Utc), 5, 160, 8 },
                    { 161, "Excellent service, easy to find the spot.", new DateTime(2025, 8, 2, 14, 30, 0, 0, DateTimeKind.Utc), 4, 161, 9 },
                    { 162, "Smooth parking process, highly recommended!", new DateTime(2025, 8, 10, 9, 30, 0, 0, DateTimeKind.Utc), 5, 162, 10 },
                    { 163, "Top notch facility, will use again.", new DateTime(2025, 8, 18, 18, 30, 0, 0, DateTimeKind.Utc), 4, 163, 11 },
                    { 164, "Simple and fast, exactly what I needed.", new DateTime(2025, 8, 26, 14, 30, 0, 0, DateTimeKind.Utc), 5, 164, 12 },
                    { 165, "Great experience, very convenient!", new DateTime(2025, 8, 7, 12, 30, 0, 0, DateTimeKind.Utc), 4, 165, 1 },
                    { 166, "Excellent service, easy to find the spot.", new DateTime(2025, 8, 15, 20, 30, 0, 0, DateTimeKind.Utc), 5, 166, 2 },
                    { 167, "Smooth parking process, highly recommended!", new DateTime(2025, 8, 23, 14, 30, 0, 0, DateTimeKind.Utc), 4, 167, 3 },
                    { 168, "Top notch facility, will use again.", new DateTime(2025, 8, 4, 12, 30, 0, 0, DateTimeKind.Utc), 5, 168, 4 },
                    { 169, "Simple and fast, exactly what I needed.", new DateTime(2025, 9, 11, 20, 30, 0, 0, DateTimeKind.Utc), 4, 169, 1 },
                    { 170, "Great experience, very convenient!", new DateTime(2025, 9, 19, 18, 30, 0, 0, DateTimeKind.Utc), 5, 170, 2 },
                    { 171, "Excellent service, easy to find the spot.", new DateTime(2025, 9, 27, 12, 30, 0, 0, DateTimeKind.Utc), 4, 171, 3 },
                    { 172, "Smooth parking process, highly recommended!", new DateTime(2025, 9, 8, 20, 30, 0, 0, DateTimeKind.Utc), 5, 172, 4 },
                    { 173, "Top notch facility, will use again.", new DateTime(2025, 9, 16, 18, 30, 0, 0, DateTimeKind.Utc), 4, 173, 5 },
                    { 174, "Simple and fast, exactly what I needed.", new DateTime(2025, 9, 24, 15, 30, 0, 0, DateTimeKind.Utc), 5, 174, 6 },
                    { 175, "Great experience, very convenient!", new DateTime(2025, 9, 5, 12, 30, 0, 0, DateTimeKind.Utc), 4, 175, 7 },
                    { 176, "Excellent service, easy to find the spot.", new DateTime(2025, 9, 13, 18, 30, 0, 0, DateTimeKind.Utc), 5, 176, 8 },
                    { 177, "Smooth parking process, highly recommended!", new DateTime(2025, 9, 21, 15, 30, 0, 0, DateTimeKind.Utc), 4, 177, 9 },
                    { 178, "Top notch facility, will use again.", new DateTime(2025, 9, 2, 12, 30, 0, 0, DateTimeKind.Utc), 5, 178, 10 },
                    { 179, "Simple and fast, exactly what I needed.", new DateTime(2025, 9, 10, 21, 30, 0, 0, DateTimeKind.Utc), 4, 179, 11 },
                    { 180, "Great experience, very convenient!", new DateTime(2025, 9, 18, 18, 30, 0, 0, DateTimeKind.Utc), 5, 180, 12 },
                    { 181, "Excellent service, easy to find the spot.", new DateTime(2025, 9, 26, 12, 30, 0, 0, DateTimeKind.Utc), 4, 181, 1 },
                    { 182, "Smooth parking process, highly recommended!", new DateTime(2025, 9, 6, 21, 30, 0, 0, DateTimeKind.Utc), 5, 182, 2 },
                    { 183, "Top notch facility, will use again.", new DateTime(2025, 9, 14, 18, 30, 0, 0, DateTimeKind.Utc), 4, 183, 3 },
                    { 184, "Simple and fast, exactly what I needed.", new DateTime(2025, 9, 22, 15, 30, 0, 0, DateTimeKind.Utc), 5, 184, 4 },
                    { 185, "Great experience, very convenient!", new DateTime(2025, 9, 3, 9, 30, 0, 0, DateTimeKind.Utc), 4, 185, 5 },
                    { 186, "Excellent service, easy to find the spot.", new DateTime(2025, 9, 11, 18, 30, 0, 0, DateTimeKind.Utc), 5, 186, 6 },
                    { 187, "Smooth parking process, highly recommended!", new DateTime(2025, 9, 19, 15, 30, 0, 0, DateTimeKind.Utc), 4, 187, 7 },
                    { 188, "Top notch facility, will use again.", new DateTime(2025, 9, 27, 13, 30, 0, 0, DateTimeKind.Utc), 5, 188, 8 },
                    { 189, "Simple and fast, exactly what I needed.", new DateTime(2025, 9, 8, 21, 30, 0, 0, DateTimeKind.Utc), 4, 189, 9 },
                    { 190, "Great experience, very convenient!", new DateTime(2025, 9, 16, 15, 30, 0, 0, DateTimeKind.Utc), 5, 190, 10 },
                    { 191, "Excellent service, easy to find the spot.", new DateTime(2025, 9, 24, 12, 30, 0, 0, DateTimeKind.Utc), 4, 191, 11 },
                    { 192, "Smooth parking process, highly recommended!", new DateTime(2025, 9, 5, 21, 30, 0, 0, DateTimeKind.Utc), 5, 192, 12 },
                    { 193, "Top notch facility, will use again.", new DateTime(2025, 9, 13, 19, 30, 0, 0, DateTimeKind.Utc), 4, 193, 1 },
                    { 194, "Simple and fast, exactly what I needed.", new DateTime(2025, 9, 20, 15, 30, 0, 0, DateTimeKind.Utc), 5, 194, 2 },
                    { 195, "Great experience, very convenient!", new DateTime(2025, 9, 1, 9, 30, 0, 0, DateTimeKind.Utc), 4, 195, 3 },
                    { 196, "Excellent service, easy to find the spot.", new DateTime(2025, 9, 9, 19, 30, 0, 0, DateTimeKind.Utc), 5, 196, 4 },
                    { 197, "Smooth parking process, highly recommended!", new DateTime(2025, 9, 17, 15, 30, 0, 0, DateTimeKind.Utc), 4, 197, 5 },
                    { 198, "Top notch facility, will use again.", new DateTime(2025, 9, 25, 13, 30, 0, 0, DateTimeKind.Utc), 5, 198, 6 },
                    { 199, "Simple and fast, exactly what I needed.", new DateTime(2025, 10, 6, 19, 30, 0, 0, DateTimeKind.Utc), 4, 199, 1 },
                    { 200, "Great experience, very convenient!", new DateTime(2025, 10, 14, 15, 30, 0, 0, DateTimeKind.Utc), 5, 200, 2 },
                    { 201, "Excellent service, easy to find the spot.", new DateTime(2025, 10, 22, 13, 30, 0, 0, DateTimeKind.Utc), 4, 201, 3 },
                    { 202, "Smooth parking process, highly recommended!", new DateTime(2025, 10, 3, 22, 30, 0, 0, DateTimeKind.Utc), 5, 202, 4 },
                    { 203, "Top notch facility, will use again.", new DateTime(2025, 10, 11, 18, 30, 0, 0, DateTimeKind.Utc), 4, 203, 5 },
                    { 204, "Simple and fast, exactly what I needed.", new DateTime(2025, 10, 19, 13, 30, 0, 0, DateTimeKind.Utc), 5, 204, 6 },
                    { 205, "Great experience, very convenient!", new DateTime(2025, 10, 27, 9, 30, 0, 0, DateTimeKind.Utc), 4, 205, 7 },
                    { 206, "Excellent service, easy to find the spot.", new DateTime(2025, 10, 8, 19, 30, 0, 0, DateTimeKind.Utc), 5, 206, 8 },
                    { 207, "Smooth parking process, highly recommended!", new DateTime(2025, 10, 15, 16, 30, 0, 0, DateTimeKind.Utc), 4, 207, 9 },
                    { 208, "Top notch facility, will use again.", new DateTime(2025, 10, 23, 12, 30, 0, 0, DateTimeKind.Utc), 5, 208, 10 },
                    { 209, "Simple and fast, exactly what I needed.", new DateTime(2025, 10, 4, 19, 30, 0, 0, DateTimeKind.Utc), 4, 209, 11 },
                    { 210, "Great experience, very convenient!", new DateTime(2025, 10, 12, 16, 30, 0, 0, DateTimeKind.Utc), 5, 210, 12 },
                    { 211, "Excellent service, easy to find the spot.", new DateTime(2025, 10, 20, 13, 30, 0, 0, DateTimeKind.Utc), 4, 211, 1 },
                    { 212, "Smooth parking process, highly recommended!", new DateTime(2025, 10, 1, 22, 30, 0, 0, DateTimeKind.Utc), 5, 212, 2 },
                    { 213, "Top notch facility, will use again.", new DateTime(2025, 10, 9, 16, 30, 0, 0, DateTimeKind.Utc), 4, 213, 3 },
                    { 214, "Simple and fast, exactly what I needed.", new DateTime(2025, 10, 17, 13, 30, 0, 0, DateTimeKind.Utc), 5, 214, 4 },
                    { 215, "Great experience, very convenient!", new DateTime(2025, 10, 25, 10, 30, 0, 0, DateTimeKind.Utc), 4, 215, 5 },
                    { 216, "Excellent service, easy to find the spot.", new DateTime(2025, 10, 6, 18, 30, 0, 0, DateTimeKind.Utc), 5, 216, 6 },
                    { 217, "Smooth parking process, highly recommended!", new DateTime(2025, 10, 14, 16, 30, 0, 0, DateTimeKind.Utc), 4, 217, 7 },
                    { 218, "Top notch facility, will use again.", new DateTime(2025, 10, 22, 10, 30, 0, 0, DateTimeKind.Utc), 5, 218, 8 },
                    { 219, "Simple and fast, exactly what I needed.", new DateTime(2025, 10, 3, 19, 30, 0, 0, DateTimeKind.Utc), 4, 219, 9 },
                    { 220, "Great experience, very convenient!", new DateTime(2025, 10, 10, 16, 30, 0, 0, DateTimeKind.Utc), 5, 220, 10 },
                    { 221, "Excellent service, easy to find the spot.", new DateTime(2025, 10, 18, 13, 30, 0, 0, DateTimeKind.Utc), 4, 221, 11 },
                    { 222, "Smooth parking process, highly recommended!", new DateTime(2025, 10, 26, 22, 30, 0, 0, DateTimeKind.Utc), 5, 222, 12 },
                    { 223, "Top notch facility, will use again.", new DateTime(2025, 10, 7, 16, 30, 0, 0, DateTimeKind.Utc), 4, 223, 1 },
                    { 224, "Simple and fast, exactly what I needed.", new DateTime(2025, 10, 15, 14, 30, 0, 0, DateTimeKind.Utc), 5, 224, 2 },
                    { 225, "Great experience, very convenient!", new DateTime(2025, 10, 23, 10, 30, 0, 0, DateTimeKind.Utc), 4, 225, 3 },
                    { 226, "Excellent service, easy to find the spot.", new DateTime(2025, 10, 4, 19, 30, 0, 0, DateTimeKind.Utc), 5, 226, 4 },
                    { 227, "Smooth parking process, highly recommended!", new DateTime(2025, 10, 12, 14, 30, 0, 0, DateTimeKind.Utc), 4, 227, 5 },
                    { 228, "Top notch facility, will use again.", new DateTime(2025, 10, 20, 10, 30, 0, 0, DateTimeKind.Utc), 5, 228, 6 },
                    { 229, "Simple and fast, exactly what I needed.", new DateTime(2025, 10, 1, 20, 30, 0, 0, DateTimeKind.Utc), 4, 229, 7 },
                    { 230, "Great experience, very convenient!", new DateTime(2025, 10, 9, 16, 30, 0, 0, DateTimeKind.Utc), 5, 230, 8 },
                    { 231, "Excellent service, easy to find the spot.", new DateTime(2025, 11, 17, 13, 30, 0, 0, DateTimeKind.Utc), 4, 231, 1 },
                    { 232, "Smooth parking process, highly recommended!", new DateTime(2025, 11, 25, 20, 30, 0, 0, DateTimeKind.Utc), 5, 232, 2 },
                    { 233, "Top notch facility, will use again.", new DateTime(2025, 11, 5, 16, 30, 0, 0, DateTimeKind.Utc), 4, 233, 3 },
                    { 234, "Simple and fast, exactly what I needed.", new DateTime(2025, 11, 13, 13, 30, 0, 0, DateTimeKind.Utc), 5, 234, 4 },
                    { 235, "Great experience, very convenient!", new DateTime(2025, 11, 21, 11, 30, 0, 0, DateTimeKind.Utc), 4, 235, 5 },
                    { 236, "Excellent service, easy to find the spot.", new DateTime(2025, 11, 2, 19, 30, 0, 0, DateTimeKind.Utc), 5, 236, 6 },
                    { 237, "Smooth parking process, highly recommended!", new DateTime(2025, 11, 10, 14, 30, 0, 0, DateTimeKind.Utc), 4, 237, 7 },
                    { 238, "Top notch facility, will use again.", new DateTime(2025, 11, 18, 11, 30, 0, 0, DateTimeKind.Utc), 5, 238, 8 },
                    { 239, "Simple and fast, exactly what I needed.", new DateTime(2025, 11, 26, 19, 30, 0, 0, DateTimeKind.Utc), 4, 239, 9 },
                    { 240, "Great experience, very convenient!", new DateTime(2025, 11, 7, 17, 30, 0, 0, DateTimeKind.Utc), 5, 240, 10 },
                    { 241, "Excellent service, easy to find the spot.", new DateTime(2025, 11, 15, 13, 30, 0, 0, DateTimeKind.Utc), 4, 241, 11 },
                    { 242, "Smooth parking process, highly recommended!", new DateTime(2025, 11, 23, 20, 30, 0, 0, DateTimeKind.Utc), 5, 242, 12 },
                    { 243, "Top notch facility, will use again.", new DateTime(2025, 11, 4, 17, 30, 0, 0, DateTimeKind.Utc), 4, 243, 1 },
                    { 244, "Simple and fast, exactly what I needed.", new DateTime(2025, 11, 12, 13, 30, 0, 0, DateTimeKind.Utc), 5, 244, 2 },
                    { 245, "Great experience, very convenient!", new DateTime(2025, 11, 20, 11, 30, 0, 0, DateTimeKind.Utc), 4, 245, 3 },
                    { 246, "Excellent service, easy to find the spot.", new DateTime(2025, 11, 27, 17, 30, 0, 0, DateTimeKind.Utc), 5, 246, 4 },
                    { 247, "Smooth parking process, highly recommended!", new DateTime(2025, 11, 8, 14, 30, 0, 0, DateTimeKind.Utc), 4, 247, 5 },
                    { 248, "Top notch facility, will use again.", new DateTime(2025, 11, 16, 11, 30, 0, 0, DateTimeKind.Utc), 5, 248, 6 },
                    { 249, "Simple and fast, exactly what I needed.", new DateTime(2025, 11, 24, 20, 30, 0, 0, DateTimeKind.Utc), 4, 249, 7 },
                    { 250, "Great experience, very convenient!", new DateTime(2025, 11, 5, 17, 30, 0, 0, DateTimeKind.Utc), 5, 250, 8 },
                    { 251, "Excellent service, easy to find the spot.", new DateTime(2025, 11, 13, 11, 30, 0, 0, DateTimeKind.Utc), 4, 251, 9 },
                    { 252, "Smooth parking process, highly recommended!", new DateTime(2025, 11, 21, 20, 30, 0, 0, DateTimeKind.Utc), 5, 252, 10 },
                    { 253, "Top notch facility, will use again.", new DateTime(2025, 11, 2, 17, 30, 0, 0, DateTimeKind.Utc), 4, 253, 11 },
                    { 254, "Simple and fast, exactly what I needed.", new DateTime(2025, 11, 10, 14, 30, 0, 0, DateTimeKind.Utc), 5, 254, 12 },
                    { 255, "Great experience, very convenient!", new DateTime(2025, 11, 18, 11, 30, 0, 0, DateTimeKind.Utc), 4, 255, 1 },
                    { 256, "Excellent service, easy to find the spot.", new DateTime(2025, 11, 26, 17, 30, 0, 0, DateTimeKind.Utc), 5, 256, 2 },
                    { 257, "Smooth parking process, highly recommended!", new DateTime(2025, 11, 7, 14, 30, 0, 0, DateTimeKind.Utc), 4, 257, 3 },
                    { 258, "Top notch facility, will use again.", new DateTime(2025, 11, 15, 11, 30, 0, 0, DateTimeKind.Utc), 5, 258, 4 },
                    { 259, "Simple and fast, exactly what I needed.", new DateTime(2025, 11, 22, 20, 30, 0, 0, DateTimeKind.Utc), 4, 259, 5 },
                    { 260, "Great experience, very convenient!", new DateTime(2025, 11, 3, 15, 30, 0, 0, DateTimeKind.Utc), 5, 260, 6 },
                    { 261, "Excellent service, easy to find the spot.", new DateTime(2025, 11, 11, 11, 30, 0, 0, DateTimeKind.Utc), 4, 261, 7 },
                    { 262, "Smooth parking process, highly recommended!", new DateTime(2025, 11, 19, 20, 30, 0, 0, DateTimeKind.Utc), 5, 262, 8 },
                    { 263, "Top notch facility, will use again.", new DateTime(2025, 11, 27, 18, 30, 0, 0, DateTimeKind.Utc), 4, 263, 9 },
                    { 264, "Simple and fast, exactly what I needed.", new DateTime(2025, 11, 8, 14, 30, 0, 0, DateTimeKind.Utc), 5, 264, 10 },
                    { 265, "Great experience, very convenient!", new DateTime(2025, 12, 16, 20, 30, 0, 0, DateTimeKind.Utc), 4, 265, 1 },
                    { 266, "Excellent service, easy to find the spot.", new DateTime(2025, 12, 24, 18, 30, 0, 0, DateTimeKind.Utc), 5, 266, 2 },
                    { 267, "Smooth parking process, highly recommended!", new DateTime(2025, 12, 5, 14, 30, 0, 0, DateTimeKind.Utc), 4, 267, 3 },
                    { 268, "Top notch facility, will use again.", new DateTime(2025, 12, 13, 12, 30, 0, 0, DateTimeKind.Utc), 5, 268, 4 },
                    { 269, "Simple and fast, exactly what I needed.", new DateTime(2025, 12, 21, 20, 30, 0, 0, DateTimeKind.Utc), 4, 269, 5 },
                    { 270, "Great experience, very convenient!", new DateTime(2025, 12, 2, 14, 30, 0, 0, DateTimeKind.Utc), 5, 270, 6 },
                    { 271, "Excellent service, easy to find the spot.", new DateTime(2025, 12, 10, 12, 30, 0, 0, DateTimeKind.Utc), 4, 271, 7 },
                    { 272, "Smooth parking process, highly recommended!", new DateTime(2025, 12, 17, 20, 30, 0, 0, DateTimeKind.Utc), 5, 272, 8 },
                    { 273, "Top notch facility, will use again.", new DateTime(2025, 12, 25, 18, 30, 0, 0, DateTimeKind.Utc), 4, 273, 9 },
                    { 274, "Simple and fast, exactly what I needed.", new DateTime(2025, 12, 6, 12, 30, 0, 0, DateTimeKind.Utc), 5, 274, 10 },
                    { 275, "Great experience, very convenient!", new DateTime(2025, 12, 14, 20, 30, 0, 0, DateTimeKind.Utc), 4, 275, 11 },
                    { 276, "Excellent service, easy to find the spot.", new DateTime(2025, 12, 22, 18, 30, 0, 0, DateTimeKind.Utc), 5, 276, 12 },
                    { 277, "Smooth parking process, highly recommended!", new DateTime(2025, 12, 3, 15, 30, 0, 0, DateTimeKind.Utc), 4, 277, 1 },
                    { 278, "Top notch facility, will use again.", new DateTime(2025, 12, 11, 12, 30, 0, 0, DateTimeKind.Utc), 5, 278, 2 },
                    { 279, "Simple and fast, exactly what I needed.", new DateTime(2025, 12, 19, 18, 30, 0, 0, DateTimeKind.Utc), 4, 279, 3 },
                    { 280, "Great experience, very convenient!", new DateTime(2025, 12, 27, 14, 30, 0, 0, DateTimeKind.Utc), 5, 280, 4 },
                    { 281, "Excellent service, easy to find the spot.", new DateTime(2025, 12, 8, 12, 30, 0, 0, DateTimeKind.Utc), 4, 281, 5 },
                    { 282, "Smooth parking process, highly recommended!", new DateTime(2025, 12, 16, 21, 30, 0, 0, DateTimeKind.Utc), 5, 282, 6 },
                    { 283, "Top notch facility, will use again.", new DateTime(2025, 12, 24, 17, 30, 0, 0, DateTimeKind.Utc), 4, 283, 7 },
                    { 284, "Simple and fast, exactly what I needed.", new DateTime(2025, 12, 5, 12, 30, 0, 0, DateTimeKind.Utc), 5, 284, 8 },
                    { 285, "Great experience, very convenient!", new DateTime(2025, 12, 12, 21, 30, 0, 0, DateTimeKind.Utc), 4, 285, 9 },
                    { 286, "Excellent service, easy to find the spot.", new DateTime(2025, 12, 20, 18, 30, 0, 0, DateTimeKind.Utc), 5, 286, 10 },
                    { 287, "Smooth parking process, highly recommended!", new DateTime(2025, 12, 1, 15, 30, 0, 0, DateTimeKind.Utc), 4, 287, 11 },
                    { 288, "Top notch facility, will use again.", new DateTime(2025, 12, 9, 9, 30, 0, 0, DateTimeKind.Utc), 5, 288, 12 },
                    { 289, "Simple and fast, exactly what I needed.", new DateTime(2025, 12, 17, 18, 30, 0, 0, DateTimeKind.Utc), 4, 289, 1 },
                    { 290, "Great experience, very convenient!", new DateTime(2025, 12, 25, 15, 30, 0, 0, DateTimeKind.Utc), 5, 290, 2 },
                    { 291, "Excellent service, easy to find the spot.", new DateTime(2025, 12, 6, 13, 30, 0, 0, DateTimeKind.Utc), 4, 291, 3 },
                    { 292, "Smooth parking process, highly recommended!", new DateTime(2025, 12, 14, 21, 30, 0, 0, DateTimeKind.Utc), 5, 292, 4 },
                    { 293, "Top notch facility, will use again.", new DateTime(2025, 12, 22, 15, 30, 0, 0, DateTimeKind.Utc), 4, 293, 5 },
                    { 294, "Simple and fast, exactly what I needed.", new DateTime(2025, 12, 3, 12, 30, 0, 0, DateTimeKind.Utc), 5, 294, 6 },
                    { 295, "Great experience, very convenient!", new DateTime(2025, 12, 11, 21, 30, 0, 0, DateTimeKind.Utc), 4, 295, 7 },
                    { 296, "Excellent service, easy to find the spot.", new DateTime(2025, 12, 19, 19, 30, 0, 0, DateTimeKind.Utc), 5, 296, 8 },
                    { 297, "Smooth parking process, highly recommended!", new DateTime(2025, 12, 26, 15, 30, 0, 0, DateTimeKind.Utc), 4, 297, 9 },
                    { 298, "Top notch facility, will use again.", new DateTime(2025, 12, 7, 9, 30, 0, 0, DateTimeKind.Utc), 5, 298, 10 },
                    { 299, "Simple and fast, exactly what I needed.", new DateTime(2025, 12, 15, 19, 30, 0, 0, DateTimeKind.Utc), 4, 299, 11 },
                    { 300, "Great experience, very convenient!", new DateTime(2025, 12, 23, 15, 30, 0, 0, DateTimeKind.Utc), 5, 300, 12 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Cities_Name",
                table: "Cities",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Genders_Name",
                table: "Genders",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ParkingReservations_ParkingSpotId",
                table: "ParkingReservations",
                column: "ParkingSpotId");

            migrationBuilder.CreateIndex(
                name: "IX_ParkingReservations_UserId",
                table: "ParkingReservations",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_ParkingReservations_VehicleId",
                table: "ParkingReservations",
                column: "VehicleId");

            migrationBuilder.CreateIndex(
                name: "IX_ParkingSessions_ParkingReservationId",
                table: "ParkingSessions",
                column: "ParkingReservationId");

            migrationBuilder.CreateIndex(
                name: "IX_ParkingSpots_ParkingSpotTypeId",
                table: "ParkingSpots",
                column: "ParkingSpotTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_ParkingSpots_ParkingWingId",
                table: "ParkingSpots",
                column: "ParkingWingId");

            migrationBuilder.CreateIndex(
                name: "IX_ParkingWings_ParkingSectorId",
                table: "ParkingWings",
                column: "ParkingSectorId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_ReservationId",
                table: "Reviews",
                column: "ReservationId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId",
                table: "Reviews",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Roles_Name",
                table: "Roles",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_RoleId",
                table: "UserRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_UserId_RoleId",
                table: "UserRoles",
                columns: new[] { "UserId", "RoleId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_CityId",
                table: "Users",
                column: "CityId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_GenderId",
                table: "Users",
                column: "GenderId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Username",
                table: "Users",
                column: "Username",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Vehicles_UserId",
                table: "Vehicles",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ParkingSessions");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "ParkingReservations");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "ParkingSpots");

            migrationBuilder.DropTable(
                name: "Vehicles");

            migrationBuilder.DropTable(
                name: "ParkingSpotTypes");

            migrationBuilder.DropTable(
                name: "ParkingWings");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "ParkingSectors");

            migrationBuilder.DropTable(
                name: "Cities");

            migrationBuilder.DropTable(
                name: "Genders");
        }
    }
}
