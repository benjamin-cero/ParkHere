using System;

namespace ParkHere.Subscriber.Models
{
    public class ReservationNotificationDto
    {
        public string UserEmail { get; set; } = null!;
        public string UserFullName { get; set; } = null!;
        public string VehicleLicensePlate { get; set; } = null!;
        public string ParkingSpotCode { get; set; } = null!;
        public string ParkingWingName { get; set; } = null!;
        public string ParkingSectorName { get; set; } = null!;
        public string ParkingSpotType { get; set; } = null!;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal Price { get; set; }
        public bool IsPaid { get; set; }
    }
}

