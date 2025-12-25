using System;
using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Requests
{
    public class ParkingSessionInsertRequest
    {
        public int ParkingReservationId { get; set; }
        public DateTime ActualStartTime { get; set; }
        public DateTime? ActualEndTime { get; set; }
        public int ExtraMinutes { get; set; } = 0;
        public decimal ExtraCharge { get; set; } = 0;
    }
} 