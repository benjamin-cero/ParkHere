using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace ParkHere.Services.Migrations
{
    /// <inheritdoc />
    public partial class SeedInitialData : Migration
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
                    ActualStartTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ActualEndTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ExtraMinutes = table.Column<int>(type: "int", nullable: false),
                    ExtraCharge = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
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
                    { 1, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Full system access and administrative privileges", true, "Administrator" },
                    { 2, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Standard user with limited system access", true, "User" }
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
                    { 1, 1, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "adil.joldic@parkhere.com", "Adil", 1, true, null, "Joldic", "SKCEf8PFXFpwXefUyKkpl6MMBen54WiyctXTCdWrHd0=", "aGk9AqtPuyMxuMw5kVMi5A==", "+387 61 123 456", null, "desktop" },
                    { 2, 5, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "parkhere.receive@gmail.com", "Benjamin", 1, true, null, "Cero", "+/pM4+5rgrwaezXoDcdKMtyc2Q7IM+rGT5qT8AOUBRE=", "BPiZbadjt6lpsQKO4wB1aQ==", "+387 61 123 456", null, "user" },
                    { 3, 3, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "elmir.babovic@parkhere.com", "Elmir", 1, true, null, "Babovic", "vlAx8k6vnwwlvR7VmvHyN82cIDhXROKGCAoEKA7BwFI=", "HBQrLQGqNOmja95IBkWlfw==", "+387 61 123 456", null, "admin2" },
                    { 4, 1, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "haris.horozovic@example.com", "Haris", 1, true, null, "Horozovic", "5H4NYDgDMf/fY9PDV8qW9Wz29pk05xBZ0FF4A9/Lisw=", "kqXcBL1vn7jyn4Bm/tilwQ==", "+387 61 123 456", null, "user4" },
                    { 5, 2, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "faris.festic@example.com", "Faris", 2, true, null, "Festic", "5H4NYDgDMf/fY9PDV8qW9Wz29pk05xBZ0FF4A9/Lisw=", "kqXcBL1vn7jyn4Bm/tilwQ==", "+387 61 123 456", null, "user5" },
                    { 6, 3, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "adna.adnic@example.com", "Adna", 1, true, null, "Adnic", "5H4NYDgDMf/fY9PDV8qW9Wz29pk05xBZ0FF4A9/Lisw=", "kqXcBL1vn7jyn4Bm/tilwQ==", "+387 61 123 456", null, "user6" },
                    { 7, 4, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "edin.edinic@example.com", "Edin", 2, true, null, "Edinic", "5H4NYDgDMf/fY9PDV8qW9Wz29pk05xBZ0FF4A9/Lisw=", "kqXcBL1vn7jyn4Bm/tilwQ==", "+387 61 123 456", null, "user7" },
                    { 8, 5, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "maja.majic@example.com", "Maja", 1, true, null, "Majic", "5H4NYDgDMf/fY9PDV8qW9Wz29pk05xBZ0FF4A9/Lisw=", "kqXcBL1vn7jyn4Bm/tilwQ==", "+387 61 123 456", null, "user8" },
                    { 9, 6, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "sara.saric@example.com", "Sara", 2, true, null, "Saric", "5H4NYDgDMf/fY9PDV8qW9Wz29pk05xBZ0FF4A9/Lisw=", "kqXcBL1vn7jyn4Bm/tilwQ==", "+387 61 123 456", null, "user9" },
                    { 10, 7, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "ivan.ivic@example.com", "Ivan", 1, true, null, "Ivic", "5H4NYDgDMf/fY9PDV8qW9Wz29pk05xBZ0FF4A9/Lisw=", "kqXcBL1vn7jyn4Bm/tilwQ==", "+387 61 123 456", null, "user10" },
                    { 11, 8, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "luka.lukic@example.com", "Luka", 2, true, null, "Lukic", "5H4NYDgDMf/fY9PDV8qW9Wz29pk05xBZ0FF4A9/Lisw=", "kqXcBL1vn7jyn4Bm/tilwQ==", "+387 61 123 456", null, "user11" },
                    { 12, 9, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "ana.anic@example.com", "Ana", 1, true, null, "Anic", "5H4NYDgDMf/fY9PDV8qW9Wz29pk05xBZ0FF4A9/Lisw=", "kqXcBL1vn7jyn4Bm/tilwQ==", "+387 61 123 456", null, "user12" }
                });

            migrationBuilder.InsertData(
                table: "ParkingSpots",
                columns: new[] { "Id", "IsActive", "IsOccupied", "ParkingSpotTypeId", "ParkingWingId", "SpotCode" },
                values: new object[,]
                {
                    { 1, true, false, 1, 1, "A1-  L1" },
                    { 2, true, false, 1, 2, "A1-  R1" },
                    { 3, true, false, 2, 3, "A2-  L1" },
                    { 4, true, false, 2, 4, "A2-  R1" },
                    { 5, true, false, 3, 5, "A3-  L1" },
                    { 6, true, false, 3, 6, "A3-  R1" },
                    { 7, false, false, 1, 7, "A4-  L1" },
                    { 8, false, false, 1, 8, "A4-  R1" }
                });

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "Id", "DateAssigned", "RoleId", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 2, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 2 },
                    { 3, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, 3 },
                    { 4, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 4 },
                    { 5, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 5 },
                    { 6, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 6 },
                    { 7, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 7 },
                    { 8, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 8 },
                    { 9, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 9 },
                    { 10, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 10 },
                    { 11, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 11 },
                    { 12, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, 12 }
                });

            migrationBuilder.InsertData(
                table: "Vehicles",
                columns: new[] { "Id", "IsActive", "LicensePlate", "UserId" },
                values: new object[,]
                {
                    { 1, true, "ABC-123", 1 },
                    { 2, true, "DEF-456", 2 },
                    { 3, true, "GHI-789", 3 },
                    { 4, true, "JKL-012", 4 }
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
