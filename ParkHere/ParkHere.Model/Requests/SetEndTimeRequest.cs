using System;

namespace ParkHere.Model.Requests
{
    public class SetEndTimeRequest
    {
        public int ReservationId { get; set; }
        public DateTime ActualEndTime { get; set; }
    }
}
