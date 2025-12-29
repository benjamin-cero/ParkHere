namespace ParkHere.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? ReservationId { get; set; }
        public int? Rating { get; set; }
        public string? Name { get; set; }
    }
}
