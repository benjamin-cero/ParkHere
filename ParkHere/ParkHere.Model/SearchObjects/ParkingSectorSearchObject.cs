using System.ComponentModel.DataAnnotations;

namespace ParkHere.Model.SearchObjects
{
    public class ParkingSectorSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? FloorNumber { get; set; }
    }
} 