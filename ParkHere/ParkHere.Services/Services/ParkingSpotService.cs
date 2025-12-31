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



    }
} 