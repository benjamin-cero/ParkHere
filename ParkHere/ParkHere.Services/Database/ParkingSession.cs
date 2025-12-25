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

        [Required]
        public DateTime ActualStartTime { get; set; }

        public DateTime? ActualEndTime { get; set; }

        public int ExtraMinutes { get; set; } = 0;
        public decimal ExtraCharge { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [ForeignKey(nameof(ParkingReservationId))]
        public ParkingReservation ParkingReservation { get; set; } = null!;
    }
}