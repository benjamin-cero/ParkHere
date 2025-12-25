using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Requests
{
    public class VehicleUpdateRequest
    {
        public string LicensePlate { get; set; } = null!;
        public int UserId { get; set; }
        public bool IsActive { get; set; } = true;
    }
} 