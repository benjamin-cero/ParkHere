using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Requests
{
    public class ParkingSpotUpdateRequest
    {
        public string SpotCode { get; set; } = null!;
        public int ParkingWingId { get; set; }
        public int ParkingSpotTypeId { get; set; }
        public bool IsOccupied { get; set; }
        public bool IsActive { get; set; }
    }
} 