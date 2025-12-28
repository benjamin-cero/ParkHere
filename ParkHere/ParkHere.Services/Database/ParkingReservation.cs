using ParkHere.Services.Database;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkHere.Services.Database
{
    public class ParkingReservation
    {
        [Key]
        public int Id { get; set; }

        public int UserId { get; set; }
        public int VehicleId { get; set; }
        public int ParkingSpotId { get; set; }

        public DateTime StartTime { get; set; } 
        public DateTime EndTime { get; set; } 

        public decimal Price { get; set; }
        public bool IsPaid { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [ForeignKey(nameof(UserId))]
        public User User { get; set; } = null!;

        [ForeignKey(nameof(VehicleId))]
        public Vehicle Vehicle { get; set; } = null!;

        [ForeignKey(nameof(ParkingSpotId))]
        public ParkingSpot ParkingSpot { get; set; } = null!;

        public ParkingSession? ParkingSession { get; set; }
    }
}