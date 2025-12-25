using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkHere.Services.Database
{
    public class ParkingSpot
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(20)]
        public string SpotCode { get; set; } = null!;

        public int ParkingWingId { get; set; }
        public int ParkingSpotTypeId { get; set; }

        [ForeignKey(nameof(ParkingWingId))]
        public ParkingWing ParkingWing { get; set; } = null!;

        [ForeignKey(nameof(ParkingSpotTypeId))]
        public ParkingSpotType ParkingSpotType { get; set; } = null!;

        public bool IsOccupied { get; set; } = false;
        public bool IsActive { get; set; } = true;

    }
}