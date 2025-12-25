using System;

namespace ParkHere.Model.Requests
{
    public class SetStartTimeRequest
    {
        public int ReservationId { get; set; }
        public DateTime ActualStartTime { get; set; }
    }
}
