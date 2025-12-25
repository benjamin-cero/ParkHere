using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkHere.Model.Responses
{
    public class ParkingWingResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public int ParkingSectorId { get; set; }
        public string? ParkingSectorName { get; set; }
        public bool IsActive { get; set; }
    }
} 