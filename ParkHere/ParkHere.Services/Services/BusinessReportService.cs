using Microsoft.EntityFrameworkCore;
using ParkHere.Model.Responses;
using ParkHere.Services.Database;
using ParkHere.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;

namespace ParkHere.Services.Services
{
    public class BusinessReportService : IBusinessReportService
    {
        private readonly ParkHereDbContext _context;

        public BusinessReportService(ParkHereDbContext context)
        {
            _context = context;
        }

        public async Task<BusinessReportResponse> GetBusinessReport()
        {
            var today = DateTime.Now;

            // Basic stats
            var reservations = await _context.ParkingReservations
                .Include(r => r.ParkingSpot)
                .ThenInclude(ps => ps.ParkingSpotType)
                .Include(r => r.ParkingSpot)
                .ThenInclude(ps => ps.ParkingWing)
                .ThenInclude(pw => pw.ParkingSector)
                .Include(r => r.User)
                .ThenInclude(u => u.Gender)
                .ToListAsync();

            if (!reservations.Any())
            {
                return new BusinessReportResponse
                {
                    TotalRevenue = 0,
                    TotalReservations = 0,
                    TotalUsers = await _context.Users.CountAsync(),
                    MonthlyRevenueTrends = new List<MonthlyRevenue>(),
                    SpotTypeDistribution = new List<PopularItem>(),
                    SectorDistribution = new List<PopularItem>()
                };
            }

            var totalRevenue = reservations.Sum(r => r.Price);
            var totalReservations = reservations.Count;
            var totalUsers = await _context.Users.CountAsync();

            // Monthly revenue trends for last 12 months (In-memory)
            var startDate = new DateTime(today.Year, today.Month, 1).AddMonths(-11);

            var monthlyTrends = reservations
                .Where(r => r.StartTime >= startDate)
                .GroupBy(r => new { r.StartTime.Year, r.StartTime.Month })
                .Select(g => new
                {
                    g.Key.Year,
                    g.Key.Month,
                    Revenue = g.Sum(r => r.Price)
                })
                .OrderBy(x => x.Year)
                .ThenBy(x => x.Month)
                .Select(x => new MonthlyRevenue
                {
                    Month = CultureInfo.CurrentCulture.DateTimeFormat.GetAbbreviatedMonthName(x.Month),
                    Revenue = x.Revenue
                })
                .ToList();

            // Popular Spot
            var mostPopularSpotItem = reservations
                .GroupBy(r => r.ParkingSpotId)
                .OrderByDescending(g => g.Count())
                .FirstOrDefault();

            var mostPopularSpot = mostPopularSpotItem != null ? new PopularItem
            {
                Name = mostPopularSpotItem.First().ParkingSpot.SpotCode,
                Count = mostPopularSpotItem.Count(),
                Revenue = mostPopularSpotItem.Sum(r => r.Price)
            } : null;

            // Popular Type
            var mostPopularTypeItem = reservations
                .GroupBy(r => r.ParkingSpot.ParkingSpotTypeId)
                .OrderByDescending(g => g.Count())
                .FirstOrDefault();

            var mostPopularType = mostPopularTypeItem != null ? new PopularItem
            {
                Name = mostPopularTypeItem.First().ParkingSpot.ParkingSpotType.Type,
                Count = mostPopularTypeItem.Count(),
                Revenue = mostPopularTypeItem.Sum(r => r.Price)
            } : null;

            // Popular Wing
            var mostPopularWingItem = reservations
                .GroupBy(r => r.ParkingSpot.ParkingWingId)
                .OrderByDescending(g => g.Count())
                .FirstOrDefault();

            var mostPopularWing = mostPopularWingItem != null ? new PopularItem
            {
                Name = mostPopularWingItem.First().ParkingSpot.ParkingWing.Name,
                Count = mostPopularWingItem.Count(),
                Revenue = mostPopularWingItem.Sum(r => r.Price)
            } : null;

            // Popular Sector
            var mostPopularSectorItem = reservations
                .GroupBy(r => r.ParkingSpot.ParkingWing.ParkingSectorId)
                .OrderByDescending(g => g.Count())
                .FirstOrDefault();

            var mostPopularSector = mostPopularSectorItem != null ? new PopularItem
            {
                Name = mostPopularSectorItem.First().ParkingSpot.ParkingWing.ParkingSector.Name,
                Count = mostPopularSectorItem.Count(),
                Revenue = mostPopularSectorItem.Sum(r => r.Price)
            } : null;

            // Distribution by Type
            var typeDistribution = reservations
                .GroupBy(r => r.ParkingSpot.ParkingSpotType.Type)
                .Select(g => new PopularItem
                {
                    Name = g.Key,
                    Count = g.Count(),
                    Revenue = g.Sum(r => r.Price)
                })
                .ToList();

            // Distribution by Sector
            var sectorDistribution = reservations
                .GroupBy(r => r.ParkingSpot.ParkingWing.ParkingSector.Name)
                .Select(g => new PopularItem
                {
                    Name = g.Key,
                    Count = g.Count(),
                    Revenue = g.Sum(r => r.Price)
                })
                .ToList();

            // Distribution by Gender
            var genderDistribution = reservations
                .GroupBy(r => r.User.Gender.Name)
                .Select(g => new PopularItem
                {
                    Name = g.Key,
                    Count = g.Count(),
                    Revenue = g.Sum(r => r.Price)
                })
                .ToList();

            return new BusinessReportResponse
            {
                TotalRevenue = totalRevenue,
                TotalReservations = totalReservations,
                TotalUsers = totalUsers,
                MonthlyRevenueTrends = monthlyTrends,
                MostPopularSpot = mostPopularSpot,
                MostPopularType = mostPopularType,
                MostPopularWing = mostPopularWing,
                MostPopularSector = mostPopularSector,
                SpotTypeDistribution = typeDistribution,
                SectorDistribution = sectorDistribution,
                GenderDistribution = genderDistribution
            };
        }
    }
}
