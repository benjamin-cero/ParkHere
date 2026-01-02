using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkHere.Model.Responses
{
    public class ParkingReservationResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int VehicleId { get; set; }
        public int ParkingSpotId { get; set; }

        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }

        public decimal Price { get; set; }
        public bool IsPaid { get; set; }
        public DateTime CreatedAt { get; set; }

        public UserResponse User { get; set; } = null!;
        public VehicleResponse Vehicle { get; set; } = null!;
        public ParkingSpotResponse ParkingSpot { get; set; } = null!;
        public DateTime? ActualStartTime { get; set; }
        public DateTime? ArrivalTime { get; set; }
        public DateTime? ActualEndTime { get; set; }
        public decimal? ExtraCharge { get; set; }
    }
}