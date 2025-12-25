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
    public class ParkingSessionService : BaseCRUDService<ParkingSessionResponse, ParkingSessionSearchObject, ParkingSession, ParkingSessionInsertRequest, ParkingSessionUpdateRequest>, IParkingSessionService
    {
        public ParkingSessionService(ParkHereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<ParkingSession> ApplyFilter(IQueryable<ParkingSession> query, ParkingSessionSearchObject search)
        {
            if (search.ParkingReservationId.HasValue)
                query = query.Where(x => x.ParkingReservationId == search.ParkingReservationId);

            if (search.IsActive.HasValue)
                query = query.Where(x => (x.ActualEndTime == null) == search.IsActive.Value);

            if (search.StartDateFrom.HasValue)
                query = query.Where(x => x.ActualStartTime >= search.StartDateFrom.Value);

            if (search.StartDateTo.HasValue)
                query = query.Where(x => x.ActualStartTime <= search.StartDateTo.Value);

            return query;
        }

        protected override async Task BeforeInsert(ParkingSession entity, ParkingSessionInsertRequest request)
        {
            // Provjera da li vozilo ve? ima aktivnu sesiju
            var activeSession = await _context.ParkingSessions
                .Where(s => s.ParkingReservation.VehicleId == request.ParkingReservationId && s.ActualEndTime == null)
                .FirstOrDefaultAsync();

            if (activeSession != null)
                throw new System.InvalidOperationException("Vehicle already has an active parking session.");

            entity.ActualStartTime = request.ActualStartTime;
            entity.ActualEndTime = request.ActualEndTime;
            entity.ExtraMinutes = request.ExtraMinutes;
            entity.ExtraCharge = request.ExtraCharge;
        }

        protected override async Task BeforeUpdate(ParkingSession entity, ParkingSessionUpdateRequest request)
        {
            if (request.ActualEndTime.HasValue)
                entity.ActualEndTime = request.ActualEndTime;

            entity.ExtraMinutes = request.ExtraMinutes;
            entity.ExtraCharge = request.ExtraCharge;
        }



    }
} 