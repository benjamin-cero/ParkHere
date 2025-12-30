using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Requests
{
    public class VehicleInsertRequest
    {
        public string LicensePlate { get; set; } = null!;
        public string Name { get; set; } = null!;
        public int UserId { get; set; }
        public bool IsActive { get; set; } = true;
    }
} 