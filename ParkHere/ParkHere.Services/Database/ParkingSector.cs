using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ParkHere.Services.Database
{
    public class ParkingSector
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public int FloorNumber { get; set; }
        [Required]
        public string Name { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
    }
}