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

        // Custom action 1: Set actual start time (for admin to let someone cross the ramp)
        public async Task<ParkingSessionResponse> SetActualStartTimeAsync(int reservationId, DateTime actualStartTime)
        {
            // Find the session by reservation ID
            var session = await _context.ParkingSessions
                .FirstOrDefaultAsync(s => s.ParkingReservationId == reservationId);

            if (session == null)
                throw new InvalidOperationException($"No session found for reservation ID {reservationId}.");

            if (session.ActualStartTime.HasValue)
                throw new InvalidOperationException("Actual start time has already been set for this session.");

            // Set actual start time
            session.ActualStartTime = actualStartTime;
            await _context.SaveChangesAsync();

            return _mapper.Map<ParkingSessionResponse>(session);
        }

        // Custom action 2: Set actual end time and calculate extra charges
        public async Task<ParkingSessionResponse> SetActualEndTimeAsync(int reservationId, DateTime actualEndTime)
        {
            // Find the session with its reservation
            var session = await _context.ParkingSessions
                .Include(s => s.ParkingReservation)
                .FirstOrDefaultAsync(s => s.ParkingReservationId == reservationId);

            if (session == null)
                throw new InvalidOperationException($"No session found for reservation ID {reservationId}.");

            if (session.ActualEndTime.HasValue)
                throw new InvalidOperationException("Actual end time has already been set for this session.");

            // Set actual end time
            session.ActualEndTime = actualEndTime;

            // Calculate extra charges if overstayed
            var reservationEndTime = session.ParkingReservation.EndTime;
            
            if (actualEndTime > reservationEndTime)
            {
                // Calculate extra minutes
                var extraMinutes = (int)(actualEndTime - reservationEndTime).TotalMinutes;
                session.ExtraMinutes = extraMinutes;

                // Calculate extra charge: 0.10 BAM per minute
                const decimal penaltyPerMinute = 0.10m;
                session.ExtraCharge = extraMinutes * penaltyPerMinute;
            }
            else
            {
                // Left on time or early - no penalty
                session.ExtraMinutes = 0;
                session.ExtraCharge = 0;
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<ParkingSessionResponse>(session);
        }

        // Custom action 3: Mark reservation as paid
        public async Task MarkReservationAsPaidAsync(int reservationId)
        {
            var reservation = await _context.ParkingReservations
                .FirstOrDefaultAsync(r => r.Id == reservationId);

            if (reservation == null)
                throw new InvalidOperationException($"Reservation with ID {reservationId} not found.");

            if (reservation.IsPaid)
                throw new InvalidOperationException("Reservation is already marked as paid.");

            reservation.IsPaid = true;
            await _context.SaveChangesAsync();
        }

    }
} 