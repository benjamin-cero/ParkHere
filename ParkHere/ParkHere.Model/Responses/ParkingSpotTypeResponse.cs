namespace ParkHere.Model.Responses
{
    public class ParkingSpotTypeResponse
    {
        public int Id { get; set; }
        public string Type { get; set; } = string.Empty;
        public decimal PriceMultiplier { get; set; } 
        public bool IsActive { get; set; }

    }
} 