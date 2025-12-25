using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace ParkHere.Model.SearchObjects
{
    public class ParkingSpotSearchObject : BaseSearchObject
    {
        public string? SpotCode { get; set; }
        public int? ParkingWingId { get; set; }
        public int? ParkingSpotTypeId { get; set; }
        public bool? IsOccupied { get; set; }
        public bool? IsActive { get; set; }
    }
} 