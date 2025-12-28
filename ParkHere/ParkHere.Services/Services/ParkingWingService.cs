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
    public class ParkingWingService : BaseCRUDService<ParkingWingResponse, ParkingWingSearchObject, ParkingWing, ParkingWingInsertRequest, ParkingWingUpdateRequest>, IParkingWingService
    {
        public ParkingWingService(ParkHereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<ParkingWing> ApplyFilter(IQueryable<ParkingWing> query, ParkingWingSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }
            if (search.ParkingSectorId.HasValue)
            {
                query = query.Where(x => x.ParkingSectorId == search.ParkingSectorId);
            }
            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }
            return query;
        }

        protected override async Task BeforeInsert(ParkingWing entity, ParkingWingInsertRequest request)
        {
            if (await _context.ParkingWings.AnyAsync(c => c.Name == request.Name && c.ParkingSectorId == request.ParkingSectorId))
            {
                throw new InvalidOperationException("A parking wing with this name already exists in this sector.");
            }
        }

        protected override async Task BeforeUpdate(ParkingWing entity, ParkingWingUpdateRequest request)
        {
            if (await _context.ParkingWings.AnyAsync(c => c.Name == request.Name
                && c.ParkingSectorId == request.ParkingSectorId
                && c.Id != entity.Id))
            {
                throw new InvalidOperationException("A parking wing with this name already exists in this sector.");
            }
        }

        protected override async Task AfterUpdate(ParkingWing entity, ParkingWingUpdateRequest request)
        {
            // Cascade IsActive status to all spots in this wing
            var spots = await _context.ParkingSpots
                .Where(s => s.ParkingWingId == entity.Id)
                .ToListAsync();

            foreach (var spot in spots)
            {
                spot.IsActive = entity.IsActive;
            }
        }
    }
}

 