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
    }
} 