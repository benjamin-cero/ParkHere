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
                .Include(x => x.ParkingWing).ThenInclude(x => x.ParkingSector)
                .Include(x => x.ParkingSpotType)
                .Where(x => x.IsActive && !x.IsOccupied)
                .ToListAsync();

            if (!allSpots.Any()) return null;

            // 1. Get User's Recent Favorites (Immediate adapt for "Meho")
            var recentHighReviews = await _context.Reviews
                .Include(r => r.ParkingReservation)
                    .ThenInclude(pr => pr.ParkingSpot)
                        .ThenInclude(ps => ps.ParkingWing)
                .Where(r => r.UserId == userId && r.Rating >= 4)
                .OrderByDescending(r => r.CreatedAt).Take(5).ToListAsync();

            var favTypes = recentHighReviews
                .Where(r => r.ParkingReservation?.ParkingSpot != null)
                .Select(r => r.ParkingReservation.ParkingSpot.ParkingSpotTypeId).Distinct();

            var favSectors = recentHighReviews
                .Where(r => r.ParkingReservation?.ParkingSpot?.ParkingWing != null)
                .Select(r => r.ParkingReservation.ParkingSpot.ParkingWing.ParkingSectorId).Distinct();

            // 2. Score spots (ML + Real-time Heuristic Boost)
            var scoredSpots = allSpots.Select(spot => {
                float score = RecommenderService.Predict(userId, spot.Id);
                if (favTypes.Contains(spot.ParkingSpotTypeId)) score += 3.0f; // Strong type preference
                if (favSectors.Contains(spot.ParkingWing.ParkingSectorId)) score += 1.5f; // Area preference
                return new { Spot = spot, TotalScore = score };
            }).OrderByDescending(x => x.TotalScore).ToList();

            var recommendedSpot = scoredSpots.FirstOrDefault()?.Spot;

            // 3. Fallback: Preferred Spot Types from History (if no reviews)
            if (recommendedSpot == null || !recentHighReviews.Any())
            {
                var mostFrequentType = await _context.ParkingReservations
                    .Where(r => r.UserId == userId)
                    .GroupBy(r => r.ParkingSpot.ParkingSpotTypeId)
                    .OrderByDescending(g => g.Count())
                    .Select(g => g.Key).FirstOrDefaultAsync();

                if (mostFrequentType != 0)
                    recommendedSpot = allSpots.OrderByDescending(s => s.ParkingSpotTypeId == mostFrequentType).FirstOrDefault();
            }

            // 4. Random Fallback
            recommendedSpot ??= allSpots[new Random().Next(allSpots.Count)];

            return _mapper.Map<ParkingSpotResponse>(recommendedSpot);
        }
    }
}