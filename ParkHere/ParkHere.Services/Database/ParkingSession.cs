using ParkHere.Services.Database;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkHere.Services.Database
{
    public class ParkingSession
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int ParkingReservationId { get; set; }

        public DateTime? ActualStartTime { get; set; }
        public DateTime? ArrivalTime { get; set; }
        public DateTime? ActualEndTime { get; set; }

        public int? ExtraMinutes { get; set; }
        public decimal? ExtraCharge { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [ForeignKey(nameof(ParkingReservationId))]
        public ParkingReservation ParkingReservation { get; set; } = null!;
    }
}