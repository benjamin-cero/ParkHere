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
    public class ParkingSectorService : BaseCRUDService<ParkingSectorResponse, ParkingSectorSearchObject, ParkingSector, ParkingSectorUpsertRequest, ParkingSectorUpsertRequest>, IParkingSectorService
    {
        public ParkingSectorService(ParkHereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<ParkingSector> ApplyFilter(IQueryable<ParkingSector> query, ParkingSectorSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }
            if (search.FloorNumber.HasValue)
            {
                query = query.Where(x => x.FloorNumber == search.FloorNumber);
            }
            return query;
        }

        protected override async Task BeforeInsert(ParkingSector entity, ParkingSectorUpsertRequest request)
        {
            if (await _context.ParkingSectors.AnyAsync(c => c.Name == request.Name))
            {
                throw new InvalidOperationException("A parking sector name with this name already exists.");
            }
            if (await _context.ParkingSectors.AnyAsync(c => c.FloorNumber == request.FloorNumber))
            {
                throw new InvalidOperationException("A parking sector floor number with this number already exists.");
            }
        }

        protected override async Task BeforeUpdate(ParkingSector entity, ParkingSectorUpsertRequest request)
        {
            // Validation removed - causing issues with frontend requests
            // TODO: Re-implement with proper DTO validation if needed for actual name/floor updates
        }


        protected override async Task AfterUpdate(ParkingSector entity, ParkingSectorUpsertRequest request)
        {
            // Cascade IsActive status to all wings and their spots
            var wings = await _context.ParkingWings
                .Where(w => w.ParkingSectorId == entity.Id)
                .ToListAsync();

            foreach (var wing in wings)
            {
                wing.IsActive = entity.IsActive;
                
                // Cascade to spots in this wing
                var spots = await _context.ParkingSpots
                    .Where(s => s.ParkingWingId == wing.Id)
                    .ToListAsync();
                    
                foreach (var spot in spots)
                {
                    spot.IsActive = entity.IsActive;
                }
            }
        }

    }
}
