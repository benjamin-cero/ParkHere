using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace ParkHere.Model.SearchObjects
{
    public class ParkingWingSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? ParkingSectorId { get; set; }
        public bool? IsActive { get; set; }
    }
} 