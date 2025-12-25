using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace ParkHere.Model.SearchObjects
{
    public class ParkingSessionSearchObject : BaseSearchObject
    {
        public int? ParkingReservationId { get; set; }
        public bool? IsActive { get; set; } // mo�e� izra?unati iz ActualEndTime == null
        public DateTime? StartDateFrom { get; set; }
        public DateTime? StartDateTo { get; set; }
    }
} 