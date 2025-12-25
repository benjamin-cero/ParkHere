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
    public class VehicleService : BaseCRUDService<VehicleResponse, VehicleSearchObject, Vehicle, VehicleInsertRequest, VehicleUpdateRequest>, IVehicleService
    {
        public VehicleService(ParkHereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Vehicle> ApplyFilter(IQueryable<Vehicle> query, VehicleSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.LicensePlate))
            {
                query = query.Where(x => x.LicensePlate.Contains(search.LicensePlate));
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }
            return query;
        }

        protected override async Task BeforeInsert(Vehicle entity, VehicleInsertRequest request)
        {
            if (await _context.Vehicles.AnyAsync(v => v.LicensePlate == request.LicensePlate))
            {
                throw new InvalidOperationException("A vehicle with this license plate already exists.");
            }
        }

        protected override async Task BeforeUpdate(Vehicle entity, VehicleUpdateRequest request)
        {
            if (await _context.Vehicles.AnyAsync(v => v.LicensePlate == request.LicensePlate && v.Id != entity.Id))
            {
                throw new InvalidOperationException("A vehicle with this license plate already exists.");
            }
        }
    }
} 