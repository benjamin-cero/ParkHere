using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkHere.Model.Responses
{
    public class ParkingSessionResponse
    {
        public int Id { get; set; }
        public int ParkingReservationId { get; set; }
        public DateTime ActualStartTime { get; set; }
        public DateTime? ActualEndTime { get; set; }
        public int ExtraMinutes { get; set; }
        public decimal ExtraCharge { get; set; }
        public DateTime CreatedAt { get; set; }
    }
} 