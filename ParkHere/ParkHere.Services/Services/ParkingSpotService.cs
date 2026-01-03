using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Database;
using ParkHere.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace ParkHere.Services.Services
{
    public class ParkingSpotService : BaseCRUDService<ParkingSpotResponse, ParkingSpotSearchObject, ParkingSpot, ParkingSpotInsertRequest, ParkingSpotUpdateRequest>, IParkingSpotService
    {
        public ParkingSpotService(ParkHereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<ParkingSpot> ApplyFilter(IQueryable<ParkingSpot> query, ParkingSpotSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.SpotCode))
            {
                query = query.Where(x => x.SpotCode.Contains(search.SpotCode));
            }
            if (search.ParkingWingId.HasValue)
            {
                query = query.Where(x => x.ParkingWingId == search.ParkingWingId);
            }
            if (search.ParkingSpotTypeId.HasValue)
            {
                query = query.Where(x => x.ParkingSpotTypeId == search.ParkingSpotTypeId);
            }
            if (search.IsOccupied.HasValue)
            {
                query = query.Where(x => x.IsOccupied == search.IsOccupied.Value);
            }
            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            if (search.ParkingSectorId.HasValue)
            {
                query = query.Where(x => x.ParkingWing.ParkingSectorId == search.ParkingSectorId);
            }

            query = query.Include(x => x.ParkingWing).ThenInclude(x => x.ParkingSector);
            
            return query;
        }

        protected override async Task BeforeInsert(ParkingSpot entity, ParkingSpotInsertRequest request)
        {
            if (await _context.ParkingSpots.AnyAsync(x => x.SpotCode == request.SpotCode && x.ParkingWingId == request.ParkingWingId))
            {
                throw new InvalidOperationException("A parking spot with this code already exists in the selected wing.");
            }
        }

        protected override async Task BeforeUpdate(ParkingSpot entity, ParkingSpotUpdateRequest request)
        {
            if (await _context.ParkingSpots.AnyAsync(x => x.SpotCode == request.SpotCode && x.ParkingWingId == request.ParkingWingId && x.Id != entity.Id))
            {
                throw new InvalidOperationException("A parking spot with this code already exists in the selected wing.");
            }
        }

        public async Task<ParkingSpotResponse?> Recommend(int userId)
        {
            var allSpots = await _context.ParkingSpots
                .Include(x => x.ParkingWing)
                .ThenInclude(x => x.ParkingSector)
                .Include(x => x.ParkingSpotType)
                .Where(x => x.IsActive && !x.IsOccupied)
                .ToListAsync();

            if (!allSpots.Any()) return null;

            ParkingSpot? recommendedSpot = null;

            if (RecommenderService.IsModelAvailable())
            {
                recommendedSpot = allSpots
                    .Select(spot => new { Spot = spot, Score = RecommenderService.Predict(userId, spot.Id) })
                    .OrderByDescending(x => x.Score)
                    .FirstOrDefault()?.Spot;
            }

            // Heuristic Fallback: Preferred Spot Types from History
            if (recommendedSpot == null)
            {
                var userHistory = await _context.ParkingReservations
                    .Where(r => r.UserId == userId)
                    .OrderByDescending(r => r.StartTime)
                    .Take(10)
                    .Select(r => r.ParkingSpotId)
                    .ToListAsync();

                if (userHistory.Any())
                {
                    // Find the most frequent spot type in history
                    var mostFrequentType = await _context.ParkingReservations
                        .Where(r => r.UserId == userId)
                        .GroupBy(r => r.ParkingSpot.ParkingSpotTypeId)
                        .OrderByDescending(g => g.Count())
                        .Select(g => g.Key)
                        .FirstOrDefaultAsync();

                    recommendedSpot = allSpots
                        .OrderByDescending(s => s.ParkingSpotTypeId == mostFrequentType)
                        .ThenByDescending(s => userHistory.Contains(s.Id))
                        .FirstOrDefault();
                }
                else
                {
                    // Random spot if no history
                    var random = new Random();
                    recommendedSpot = allSpots[random.Next(allSpots.Count)];
                }
            }

            return recommendedSpot != null ? _mapper.Map<ParkingSpotResponse>(recommendedSpot) : null;
        }
    }
}