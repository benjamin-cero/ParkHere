using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace ParkHere.Model.Requests
{
    public class ParkingSectorUpsertRequest
    {
        [Required]
        public int FloorNumber { get; set; }
        [Required]
        public string Name { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;

    }
}
