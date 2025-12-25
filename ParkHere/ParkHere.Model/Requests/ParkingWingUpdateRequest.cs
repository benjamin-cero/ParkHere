using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Requests
{
    public class ParkingWingUpdateRequest
    {
        [Required]
        public string Name { get; set; } = null!;

        [Required]
        public int ParkingSectorId { get; set; }

        public bool IsActive { get; set; }
    }
} 