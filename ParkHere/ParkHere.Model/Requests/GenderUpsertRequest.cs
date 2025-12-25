using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.Requests
{
    public class GenderUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
    }
} 