using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ParkHere.Services.Database
{
    public class ParkingSpotType
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Type { get; set; } = string.Empty;

        [Required]
        public decimal PriceMultiplier { get; set; } = 1.0m;

        public bool IsActive { get; set; } = true;

    }
}