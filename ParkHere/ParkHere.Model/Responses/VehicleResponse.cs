using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkHere.Model.Responses
{
    public class VehicleResponse
    {
        public int Id { get; set; }
        public string LicensePlate { get; set; } = null!;
        public string Name { get; set; } = null!;
        public int UserId { get; set; }
        public bool IsActive { get; set; }
    }
} 