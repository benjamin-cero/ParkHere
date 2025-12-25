using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace ParkHere.Model.Requests
{
    public class ParkingSpotTypeUpsertRequest
    {

        [Required]
        [MaxLength(50)]
        public string Type { get; set; } = string.Empty;

        [Required]
        public decimal PriceMultiplier { get; set; } = 1.0m;

        public bool IsActive { get; set; } = true;

    }
}
