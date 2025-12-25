using ParkHere.Services.Database;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkHere.Services.Database
{
    public class ParkingWing
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = null!;
        public int ParkingSectorId { get; set; }

        [ForeignKey(nameof(ParkingSectorId))]
        public ParkingSector ParkingSector { get; set; } = null!;
        public bool IsActive { get; set; } = true;
    }
}