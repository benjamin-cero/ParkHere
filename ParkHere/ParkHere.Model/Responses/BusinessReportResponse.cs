using System;
using System.Collections.Generic;

namespace ParkHere.Model.Responses
{
    public class BusinessReportResponse
    {
        public decimal TotalRevenue { get; set; }
        public int TotalReservations { get; set; }
        public int TotalUsers { get; set; }
        
        public List<MonthlyRevenue> MonthlyRevenueTrends { get; set; } = new List<MonthlyRevenue>();
        
        public PopularItem? MostPopularSpot { get; set; }
        public PopularItem? MostPopularType { get; set; }
        public PopularItem? MostPopularWing { get; set; }
        public PopularItem? MostPopularSector { get; set; }

        public List<PopularItem> SpotTypeDistribution { get; set; } = new List<PopularItem>();
        public List<PopularItem> SectorDistribution { get; set; } = new List<PopularItem>();
        public List<PopularItem> GenderDistribution { get; set; } = new List<PopularItem>();
    }

    public class MonthlyRevenue
    {
        public string Month { get; set; } = null!;
        public decimal Revenue { get; set; }
    }

    public class PopularItem
    {
        public string Name { get; set; } = null!;
        public int Count { get; set; }
        public decimal? Revenue { get; set; }
    }
}
