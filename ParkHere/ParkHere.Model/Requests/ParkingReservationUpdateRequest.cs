using System;
using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Requests
{
    public class ParkingReservationUpdateRequest
    {
        public int? ParkingSpotId { get; set; }

        public int? VehicleId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
    }
} 