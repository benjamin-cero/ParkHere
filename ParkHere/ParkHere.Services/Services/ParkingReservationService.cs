using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Database;
using ParkHere.Services.Interfaces;
using ParkHere.Subscriber.Models;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using EasyNetQ;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace ParkHere.Services.Services
{
    public class ParkingReservationService : BaseCRUDService<ParkingReservationResponse, ParkingReservationSearchObject, ParkingReservation, ParkingReservationInsertRequest, ParkingReservationUpdateRequest>, IParkingReservationService
    {
        public ParkingReservationService(ParkHereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<ParkingReservation> ApplyFilter(IQueryable<ParkingReservation> query, ParkingReservationSearchObject search)
        {
            query = query.Include(x => x.User)
                         .Include(x => x.Vehicle)
                         .Include(x => x.ParkingSpot)
                            .ThenInclude(ps => ps.ParkingWing)
                                .ThenInclude(pw => pw.ParkingSector)
                         .Include(x => x.ParkingSpot)
                            .ThenInclude(ps => ps.ParkingSpotType);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId);

            if (search.VehicleId.HasValue)
                query = query.Where(x => x.VehicleId == search.VehicleId);

            if (search.ParkingSpotId.HasValue)
                query = query.Where(x => x.ParkingSpotId == search.ParkingSpotId);

            if (search.IsPaid.HasValue)
                query = query.Where(x => x.IsPaid == search.IsPaid);

            if (!string.IsNullOrEmpty(search.LicensePlate))
            {
                query = query.Where(x => x.Vehicle.LicensePlate.Contains(search.LicensePlate));
            }

            if (!string.IsNullOrEmpty(search.FullName))
            {
                var searchLower = search.FullName.ToLower();
                query = query.Where(x => (x.User.FirstName + " " + x.User.LastName).ToLower().Contains(searchLower));
            }

            if (search.ExcludePassed == true)
            {
                query = query.Where(x => x.EndTime > DateTime.Now);
            }

            query = query.OrderByDescending(x => x.StartTime);

            return query;
        }

        protected override async Task BeforeInsert(ParkingReservation entity, ParkingReservationInsertRequest request)
        {
            // Prevent booking in the past
            if (request.StartTime < DateTime.Now)
            {
                throw new InvalidOperationException("Cannot create a reservation with a start time in the past.");
            }

            var effectiveReservations = _context.ParkingReservations
               .Where(x => x.ParkingSpotId == request.ParkingSpotId)
               .Select(x => new
               {
                   x.Id,
                   x.StartTime,
                   // If session exists and has ActualEndTime (user exited), use it. Otherwise use scheduled EndTime.
                   EndTime = _context.ParkingSessions
                       .Where(s => s.ParkingReservationId == x.Id)
                       .Select(s => s.ActualEndTime)
                       .FirstOrDefault() ?? x.EndTime
               });

            bool conflict = await effectiveReservations
               .AnyAsync(x => request.StartTime < x.EndTime && x.StartTime < request.EndTime);

            if (conflict)
                throw new InvalidOperationException("Parking spot is already reserved in this time range.");
        }

        public override async Task<ParkingReservationResponse> CreateAsync(ParkingReservationInsertRequest request)
        {
            // Fetch the parking spot to get the type multiplier
            var parkingSpot = await _context.ParkingSpots
                .Include(ps => ps.ParkingSpotType)
                .FirstOrDefaultAsync(ps => ps.Id == request.ParkingSpotId);

            if (parkingSpot == null)
                throw new InvalidOperationException("Parking spot not found.");

            // Calculate duration in hours
            var duration = (request.EndTime - request.StartTime).TotalHours;
            if (duration <= 0)
                throw new InvalidOperationException("End time must be after start time.");

            // Calculate price: 3 BAM per hour * multiplier
            const decimal baseHourlyRate = 3.0m;
            decimal multiplier = parkingSpot.ParkingSpotType?.PriceMultiplier ?? 1.0m;
            decimal originalPrice = (decimal)duration * baseHourlyRate * multiplier;

            // NO-SHOW DEBT LOGIC
            var noShowReservations = await _context.ParkingReservations
                .Where(r => r.UserId == request.UserId && r.IsPaid == false && r.EndTime < DateTime.Now)
                .ToListAsync();

            decimal totalDebt = 0;
            foreach (var nr in noShowReservations)
            {
                var sessionExistsAndStarted = await _context.ParkingSessions
                    .AnyAsync(s => s.ParkingReservationId == nr.Id && s.ActualStartTime != null);

                if (!sessionExistsAndStarted)
                {
                    totalDebt += nr.Price;
                    nr.IsPaid = true; // Settle the debt by marking the no-show as paid
                }
            }

            var entity = new ParkingReservation();
            MapInsertToEntity(entity, request);
            
            // Set the calculated price (Original + Debt)
            entity.Price = Math.Round(originalPrice + totalDebt, 2);
            
            _context.ParkingReservations.Add(entity);

            await BeforeInsert(entity, request);

            await _context.SaveChangesAsync();
            
            // Create the parking session automatically
            var session = new ParkingSession
            {
                ParkingReservationId = entity.Id,
                ActualStartTime = null,
                ActualEndTime = null,
                ExtraMinutes = null,
                ExtraCharge = null,
                CreatedAt = DateTime.UtcNow
            };
            
            _context.ParkingSessions.Add(session);
            await _context.SaveChangesAsync();
            
            // Send notification after successful creation
            await SendReservationNotificationAsync(entity.Id);
            
            var response = MapToResponse(entity);
            response.IncludedDebt = totalDebt > 0 ? totalDebt : null;

            return response;
        }

        public async Task<decimal> GetDebtAsync(int userId)
        {
            var noShowReservations = await _context.ParkingReservations
                .Where(r => r.UserId == userId && r.IsPaid == false && r.EndTime < DateTime.Now)
                .ToListAsync();

            decimal totalDebt = 0;
            foreach (var nr in noShowReservations)
            {
                var sessionExistsAndStarted = await _context.ParkingSessions
                    .AnyAsync(s => s.ParkingReservationId == nr.Id && s.ActualStartTime != null);

                if (!sessionExistsAndStarted)
                {
                    totalDebt += nr.Price;
                }
            }

            return Math.Round(totalDebt, 2);
        }

        private async Task SendReservationNotificationAsync(int reservationId)
        {
            try
            {
                var reservation = await _context.ParkingReservations
                    .Include(r => r.User)
                    .Include(r => r.Vehicle)
                    .Include(r => r.ParkingSpot)
                        .ThenInclude(ps => ps.ParkingWing)
                            .ThenInclude(pw => pw.ParkingSector)
                    .Include(r => r.ParkingSpot)
                        .ThenInclude(ps => ps.ParkingSpotType)
                    .FirstOrDefaultAsync(r => r.Id == reservationId);

                if (reservation == null || string.IsNullOrWhiteSpace(reservation.User?.Email))
                {
                    return;
                }

                var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
                var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
                var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
                var virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

                using var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

                var notification = new ReservationNotification
                {
                    Reservation = new ReservationNotificationDto
                    {
                        UserEmail = reservation.User.Email,
                        UserFullName = $"{reservation.User.FirstName} {reservation.User.LastName}".Trim(),
                        VehicleLicensePlate = reservation.Vehicle?.LicensePlate ?? string.Empty,
                        ParkingSpotCode = reservation.ParkingSpot?.SpotCode ?? string.Empty,
                        ParkingWingName = reservation.ParkingSpot?.ParkingWing?.Name ?? string.Empty,
                        ParkingSectorName = reservation.ParkingSpot?.ParkingWing?.ParkingSector?.Name ?? string.Empty,
                        ParkingSpotType = reservation.ParkingSpot?.ParkingSpotType?.Type ?? string.Empty,
                        StartTime = reservation.StartTime,
                        EndTime = reservation.EndTime,
                        Price = reservation.Price,
                        IsPaid = reservation.IsPaid
                    }
                };

                await bus.PubSub.PublishAsync(notification);
            }
            catch (Exception ex)
            {
                // Log error but don't throw - notification failure shouldn't break reservation creation
                Console.WriteLine($"Failed to send reservation notification: {ex.Message}");
            }
        }
        

        protected override async Task BeforeUpdate(ParkingReservation entity, ParkingReservationUpdateRequest request)
        {
            var session = await _context.ParkingSessions
                .FirstOrDefaultAsync(x => x.ParkingReservationId == entity.Id);

            // 0. Prevent updating pending reservations to past times
            bool isPending = session?.ActualStartTime == null;
            if (isPending && request.StartTime < DateTime.Now)
            {
                throw new InvalidOperationException("Cannot update a pending reservation with a start time in the past.");
            }

            // 1. Vehicle Change Restriction: Cannot change vehicle if already entered
            // Only check if VehicleId is provided in request
            if (request.VehicleId.HasValue && entity.VehicleId != request.VehicleId.Value && session?.ActualStartTime != null)
            {
                throw new InvalidOperationException("Cannot change vehicle after entry. Please contact support if needed.");
            }

            // 2. Time Extension Rules:
            // Allow active sessions to extend time even if original EndTime passed
            bool isActiveSession = session?.ActualStartTime != null && session?.ActualEndTime == null;

            // Prevent shortening active sessions
            if (isActiveSession && request.EndTime < entity.EndTime)
            {
                throw new InvalidOperationException("Cannot shorten an active session. You can only extend the time.");
            }

            if (request.EndTime > entity.EndTime && !isActiveSession)
            {
                // If reservation is already expired
                if (DateTime.UtcNow > entity.EndTime)
                {
                    // Allow extension only within 30 minutes of expiry
                    if ((DateTime.UtcNow - entity.EndTime).TotalMinutes > 30)
                    {
                        throw new InvalidOperationException("Too late to extend. Reservation expired more than 30 minutes ago.");
                    }
                }
            }

            // Recalculate Price
            var duration = (request.EndTime - request.StartTime).TotalHours;
            if (duration > 0)
            {
                 var parkingSpot = await _context.ParkingSpots
                    .Include(ps => ps.ParkingSpotType)
                    .FirstOrDefaultAsync(ps => ps.Id == entity.ParkingSpotId);

                 if (parkingSpot != null)
                 {
                    const decimal baseHourlyRate = 3.0m;
                    decimal multiplier = parkingSpot.ParkingSpotType?.PriceMultiplier ?? 1.0m;
                    decimal price = (decimal)duration * baseHourlyRate * multiplier;
                    
                    entity.Price = Math.Round(price, 2);
                 }
            }

            // 3. Conflict Check
            // Use entity.ParkingSpotId because request might not include it (if just extending time)
            int spotId = request.ParkingSpotId.HasValue ? request.ParkingSpotId.Value : entity.ParkingSpotId;

            var effectiveReservations = _context.ParkingReservations
               .Where(x => x.ParkingSpotId == spotId && x.Id != entity.Id) // Exclude current
               .Select(x => new
               {
                   x.Id,
                   x.StartTime,
                   EndTime = _context.ParkingSessions
                       .Where(s => s.ParkingReservationId == x.Id)
                       .Select(s => s.ActualEndTime)
                       .FirstOrDefault() ?? x.EndTime
               });

            bool conflict = await effectiveReservations
               .AnyAsync(x => request.StartTime < x.EndTime && x.StartTime < request.EndTime);

            if (conflict)
                throw new InvalidOperationException("Parking spot is already reserved in this time range.");
        }

        protected override ParkingReservationResponse MapToResponse(ParkingReservation entity)
        {
            var response = base.MapToResponse(entity);
            
            var session = _context.ParkingSessions
                .FirstOrDefault(x => x.ParkingReservationId == entity.Id);
                
            if (session != null)
            {
                response.ActualStartTime = session.ActualStartTime;
                response.ArrivalTime = session.ArrivalTime;
                response.ActualEndTime = session.ActualEndTime;
                response.ExtraCharge = session.ExtraCharge;
            }
            
            return response;
        }
    }
}