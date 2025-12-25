using System;
using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Requests
{
    public class ParkingReservationInsertRequest
    {
        public int UserId { get; set; }
        public int VehicleId { get; set; }
        public int ParkingSpotId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
    }
} 