using System;
using System.Collections.Generic;
using System.Text;

namespace ParkHere.Model.SearchObjects
{
    public class RoleSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public bool? IsActive { get; set; }
    }
} 