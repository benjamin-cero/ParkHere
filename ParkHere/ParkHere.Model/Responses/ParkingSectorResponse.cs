using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Responses
{
    public class ParkingSectorResponse
    {
        public int Id { get; set; }
        public int FloorNumber { get; set; }
        public string Name { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;

    }
} 