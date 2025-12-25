using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace ParkHere.Model.SearchObjects
{
    public class VehicleSearchObject : BaseSearchObject
    {
        public string? LicensePlate { get; set; }
        public int? UserId { get; set; }
        public bool? IsActive { get; set; }
    }
} 