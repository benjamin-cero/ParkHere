using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace ParkHere.Model.SearchObjects
{
    public class ParkingReservationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? VehicleId { get; set; }
        public int? ParkingSpotId { get; set; }
        public bool? IsPaid { get; set; }
    }
} 