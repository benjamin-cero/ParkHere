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
            query = query.Include(x => x.ParkingReservation)
                            .ThenInclude(r => r.User)
                         .Include(x => x.ParkingReservation)
                            .ThenInclude(r => r.Vehicle)
                         .Include(x => x.ParkingReservation)
                            .ThenInclude(r => r.ParkingSpot)
                                .ThenInclude(ps => ps.ParkingWing)
                                    .ThenInclude(pw => pw.ParkingSector)
                         .Include(x => x.ParkingReservation)
                            .ThenInclude(r => r.ParkingSpot)
                                .ThenInclude(ps => ps.ParkingSpotType);

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

        // Custom action 1: Register arrival (for user app, or simulated by admin)
        public async Task<ParkingSessionResponse> RegisterArrivalAsync(int reservationId)
        {
            var session = await _context.ParkingSessions
                .FirstOrDefaultAsync(s => s.ParkingReservationId == reservationId);

            if (session == null)
                throw new InvalidOperationException($"No session found for reservation ID {reservationId}.");

            if (session.ArrivalTime.HasValue)
                throw new InvalidOperationException("Arrival time has already been registered for this session.");

            session.ArrivalTime = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return _mapper.Map<ParkingSessionResponse>(session);
        }

        // Custom action 2: Set actual start time (for admin to let someone cross the ramp)
        public async Task<ParkingSessionResponse> SetActualStartTimeAsync(int reservationId)
        {
            // Find the session by reservation ID with reservation details
            var session = await _context.ParkingSessions
                .Include(s => s.ParkingReservation)
                .FirstOrDefaultAsync(s => s.ParkingReservationId == reservationId);

            if (session == null)
                throw new InvalidOperationException($"No session found for reservation ID {reservationId}.");

            if (session.ActualStartTime.HasValue)
                throw new InvalidOperationException("Actual start time has already been set for this session.");

            // Calculate actual start time based on user requirements:
            // If they arrive early, use ArrivalTime. 
            // If they arrive late (or time is just right), use the Reserved Start Time.
            // If no ArrivalTime was set (legacy or direct entry), use current time.
            
            DateTime now = DateTime.UtcNow;
            DateTime reservedStart = session.ParkingReservation.StartTime;
            DateTime arrival = session.ArrivalTime ?? now;

            // Simple logic: session starts at the EARLIER of (Arrival, ReservedStart)
            // But if they are late, we start at ReservedStart.
            // If they are early, we start at Arrival.
            session.ActualStartTime = arrival < reservedStart ? arrival : reservedStart;

            await _context.SaveChangesAsync();

            return _mapper.Map<ParkingSessionResponse>(session);
        }

        // Custom action 2: Set actual end time and calculate extra charges
        public async Task<ParkingSessionResponse> SetActualEndTimeAsync(int reservationId, DateTime actualEndTime)
        {
            var session = await _context.ParkingSessions
                .Include(s => s.ParkingReservation)
                    .ThenInclude(r => r.ParkingSpot)
                        .ThenInclude(ps => ps.ParkingSpotType)
                .FirstOrDefaultAsync(s => s.ParkingReservationId == reservationId);

            if (session == null)
                throw new InvalidOperationException($"No session found for reservation ID {reservationId}.");

            if (session.ActualEndTime.HasValue)
                throw new InvalidOperationException("Actual end time has already been set for this session.");

            session.ActualEndTime = actualEndTime;

            var reservationEndTime = session.ParkingReservation.EndTime;
            var parkingSpot = session.ParkingReservation.ParkingSpot;
            
            if (actualEndTime > reservationEndTime)
            {
                var extraMinutes = (int)(actualEndTime - reservationEndTime).TotalMinutes;
                session.ExtraMinutes = extraMinutes;

                // Penalty Calculation: 1.5x the base rate
                const decimal baseHourlyRate = 3.0m;
                decimal multiplier = parkingSpot.ParkingSpotType?.PriceMultiplier ?? 1.0m;
                decimal penaltyRatePerMinute = (baseHourlyRate * multiplier / 60.0m) * 1.5m;
                
                session.ExtraCharge = Math.Round(extraMinutes * penaltyRatePerMinute, 2);
            }
            else
            {
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