using System;
using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Requests
{
    public class ParkingSessionUpdateRequest
    {
        public DateTime? ActualEndTime { get; set; }
        public int ExtraMinutes { get; set; }
        public decimal ExtraCharge { get; set; }
    }
} 