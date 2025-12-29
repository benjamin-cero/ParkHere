using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Requests
{
    public class ReviewInsertRequest
    {
        [Range(1, 5)]
        public int Rating { get; set; }
        public string? Comment { get; set; }

        [Required]
        public int UserId { get; set; }
        [Required]
        public int ReservationId { get; set; }
    }
}
