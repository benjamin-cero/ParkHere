using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkHere.Model.Responses
{
    public class ParkingSpotResponse
    {
        public int Id { get; set; }
        public string SpotCode { get; set; } = null!;
        public int ParkingWingId { get; set; }
        public int ParkingSpotTypeId { get; set; }
        public bool IsOccupied { get; set; }
        public bool IsActive { get; set; }

        public ParkingWingResponse? ParkingWing { get; set; }
        public ParkingSpotTypeResponse? ParkingSpotType { get; set; }
    }
} 