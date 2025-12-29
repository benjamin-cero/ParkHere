using System;

namespace ParkHere.Model.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public int UserId { get; set; }
        public int ReservationId { get; set; }
        public DateTime CreatedAt { get; set; }

        public UserResponse User { get; set; } = null!;
        public ParkingReservationResponse ParkingReservation { get; set; } = null!;
    }
}
