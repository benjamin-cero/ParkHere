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
    public class ParkingSpotTypeService : BaseCRUDService<ParkingSpotTypeResponse, ParkingSpotTypeSearchObject, ParkingSpotType, ParkingSpotTypeUpsertRequest, ParkingSpotTypeUpsertRequest>, IParkingSpotTypeService
    {
        public ParkingSpotTypeService(ParkHereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<ParkingSpotType> ApplyFilter(IQueryable<ParkingSpotType> query, ParkingSpotTypeSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Type))
            {
                query = query.Where(x => x.Type.Contains(search.Type));
            }

            return query;
        }

        protected override async Task BeforeInsert(ParkingSpotType entity, ParkingSpotTypeUpsertRequest request)
        {
            if (await _context.ParkingSpotTypes.AnyAsync(c => c.Type == request.Type))
            {
                throw new InvalidOperationException("A parking spot type with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(ParkingSpotType entity, ParkingSpotTypeUpsertRequest request)
        {
            if (await _context.ParkingSpotTypes.AnyAsync(c => c.Type == request.Type && c.Id != entity.Id))
            {
                throw new InvalidOperationException("A parking spot type with this name already exists.");
            }
        }


    }
} 