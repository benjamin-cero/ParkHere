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
            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId);

            if (search.VehicleId.HasValue)
                query = query.Where(x => x.VehicleId == search.VehicleId);

            if (search.ParkingSpotId.HasValue)
                query = query.Where(x => x.ParkingSpotId == search.ParkingSpotId);

            if (search.IsPaid.HasValue)
                query = query.Where(x => x.IsPaid == search.IsPaid);
            return query;
        }

        protected override async Task BeforeInsert(ParkingReservation entity, ParkingReservationInsertRequest request)
        {
            bool conflict = await _context.ParkingReservations
               .AnyAsync(x => x.ParkingSpotId == request.ParkingSpotId &&
                            ((request.StartTime >= x.StartTime && request.StartTime < x.EndTime) ||
                             (request.EndTime > x.StartTime && request.EndTime <= x.EndTime)));

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
            decimal price = (decimal)duration * baseHourlyRate * multiplier;

            var entity = new ParkingReservation();
            MapInsertToEntity(entity, request);
            
            // Set the calculated price
            entity.Price = Math.Round(price, 2);
            
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
            
            return MapToResponse(entity);
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
            bool conflict = await _context.ParkingReservations
                .AnyAsync(x => x.ParkingSpotId == request.ParkingSpotId &&
                               x.Id != entity.Id &&
                             ((request.StartTime >= x.StartTime && request.StartTime < x.EndTime) ||
                              (request.EndTime > x.StartTime && request.EndTime <= x.EndTime)));

            if (conflict)
                throw new InvalidOperationException("Parking spot is already reserved in this time range.");
        }



    }
} 