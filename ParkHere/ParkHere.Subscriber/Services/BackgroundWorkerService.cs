using EasyNetQ;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ParkHere.Subscriber.Models;
using ParkHere.Subscriber.Interfaces;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace ParkHere.Subscriber.Services
{
    public class BackgroundWorkerService : BackgroundService
    {
        private readonly ILogger<BackgroundWorkerService> _logger;
        private readonly IEmailSenderService _emailSender;
        private readonly string _host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
        private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
        private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
        private readonly string _virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

        public BackgroundWorkerService(
            ILogger<BackgroundWorkerService> logger,
            IEmailSenderService emailSender)
        {
            _logger = logger;
            _emailSender = emailSender;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var bus = RabbitHutch.CreateBus($"host={_host};virtualHost={_virtualhost};username={_username};password={_password}"))
                    {
                        // Subscribe to reservation notifications
                        bus.PubSub.Subscribe<ReservationNotification>("Reservation_Notifications", HandleReservationMessage);

                        _logger.LogInformation("Waiting for reservation notifications...");
                        await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                    }
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Error in RabbitMQ listener: {ex.Message}");
                    await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                }
            }
        }

        private async Task HandleReservationMessage(ReservationNotification notification)
        {
            var reservation = notification.Reservation;

            if (string.IsNullOrWhiteSpace(reservation.UserEmail))
            {
                _logger.LogWarning("No user email provided in the reservation notification");
                return;
            }

            var subject = "Parking Reservation Confirmation - ParkHere";
            var htmlBody = GenerateReservationEmailHtml(reservation);

            try
            {
                await _emailSender.SendEmailAsync(reservation.UserEmail, subject, htmlBody);
                _logger.LogInformation($"Reservation confirmation email sent to: {reservation.UserEmail}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to send email to {reservation.UserEmail}: {ex.Message}");
            }
        }

        private string GenerateReservationEmailHtml(ReservationNotificationDto reservation)
        {
            var duration = reservation.EndTime - reservation.StartTime;
            var durationText = duration.TotalHours < 24 
                ? $"{duration.TotalHours:F1} hours" 
                : $"{duration.TotalDays:F1} days";

            var paidIcon = reservation.IsPaid ? "✓" : "⏳";
            var paidColor = reservation.IsPaid ? "#059669" : "#d97706";

            return $@"
<!DOCTYPE html>
<html lang=""en"">
<head>
    <meta charset=""UTF-8"">
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">
    <title>Parking Reservation Confirmation</title>
</head>
<body style=""margin: 0; padding: 0; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background-color: #0f172a;"">
    <table role=""presentation"" style=""width: 100%; border-collapse: collapse; background-color: #0f172a; padding: 40px 20px;"">
        <tr>
            <td>
                <table role=""presentation"" style=""max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 0;"">
                    <!-- Top Accent Bar -->
                    <tr>
                        <td style=""background: linear-gradient(90deg, #06b6d4 0%, #3b82f6 50%, #8b5cf6 100%); height: 6px;""></td>
                    </tr>
                    
                    <!-- Header Section -->
                    <tr>
                        <td style=""background-color: #1e293b; padding: 45px 40px; text-align: center;"">
                            <h1 style=""margin: 0 0 8px 0; color: #ffffff; font-size: 32px; font-weight: 800; letter-spacing: 1px;"">PARKHERE</h1>
                            <div style=""width: 80px; height: 3px; background: #06b6d4; margin: 0 auto 20px;""></div>
                            <p style=""margin: 0; color: #cbd5e1; font-size: 14px; font-weight: 500; text-transform: uppercase; letter-spacing: 2px;"">RESERVATION CONFIRMED</p>
                        </td>
                    </tr>
                    
                    <!-- Main Content -->
                    <tr>
                        <td style=""padding: 45px 40px; background-color: #ffffff;"">
                            <p style=""margin: 0 0 30px 0; color: #0f172a; font-size: 20px; font-weight: 600; line-height: 1.4;"">
                                Hello {reservation.UserFullName},
                            </p>
                            
                            <p style=""margin: 0 0 35px 0; color: #475569; font-size: 15px; line-height: 1.7;"">
                                Your parking reservation is confirmed and ready! Here are all the details you need.
                            </p>
                            
                            <!-- Details Grid -->
                            <table role=""presentation"" style=""width: 100%; border-collapse: collapse; margin-bottom: 30px;"">
                                <tr>
                                    <td style=""padding: 0 10px 20px 0; width: 50%; vertical-align: top;"">
                                        <div style=""background-color: #f1f5f9; padding: 20px; border-left: 4px solid #06b6d4; border-radius: 4px;"">
                                            <p style=""margin: 0 0 6px 0; color: #64748b; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;"">PARKING SPOT</p>
                                            <p style=""margin: 0; color: #0f172a; font-size: 20px; font-weight: 700;"">{reservation.ParkingSpotCode}</p>
                                        </div>
                                    </td>
                                    <td style=""padding: 0 0 20px 10px; width: 50%; vertical-align: top;"">
                                        <div style=""background-color: #f1f5f9; padding: 20px; border-left: 4px solid #3b82f6; border-radius: 4px;"">
                                            <p style=""margin: 0 0 6px 0; color: #64748b; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;"">LOCATION</p>
                                            <p style=""margin: 0; color: #0f172a; font-size: 16px; font-weight: 700;"">{reservation.ParkingSectorName}</p>
                                            <p style=""margin: 4px 0 0 0; color: #475569; font-size: 14px; font-weight: 500;"">{reservation.ParkingWingName}</p>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td style=""padding: 0 10px 20px 0; width: 50%; vertical-align: top;"">
                                        <div style=""background-color: #f1f5f9; padding: 20px; border-left: 4px solid #8b5cf6; border-radius: 4px;"">
                                            <p style=""margin: 0 0 6px 0; color: #64748b; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;"">SPOT TYPE</p>
                                            <p style=""margin: 0; color: #0f172a; font-size: 18px; font-weight: 700;"">{reservation.ParkingSpotType}</p>
                                        </div>
                                    </td>
                                    <td style=""padding: 0 0 20px 10px; width: 50%; vertical-align: top;"">
                                        <div style=""background-color: #f1f5f9; padding: 20px; border-left: 4px solid #ec4899; border-radius: 4px;"">
                                            <p style=""margin: 0 0 6px 0; color: #64748b; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;"">VEHICLE</p>
                                            <p style=""margin: 0; color: #0f172a; font-size: 18px; font-weight: 700;"">{reservation.VehicleLicensePlate}</p>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                            
                            <!-- Time Section -->
                            <table role=""presentation"" style=""width: 100%; border-collapse: collapse; margin-bottom: 30px; background-color: #f8fafc; border-radius: 8px; overflow: hidden;"">
                                <tr>
                                    <td style=""padding: 25px; width: 50%; border-right: 2px solid #e2e8f0;"">
                                        <p style=""margin: 0 0 8px 0; color: #64748b; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;"">START TIME</p>
                                        <p style=""margin: 0 0 4px 0; color: #0f172a; font-size: 18px; font-weight: 700;"">{reservation.StartTime:MMM dd}</p>
                                        <p style=""margin: 0; color: #475569; font-size: 14px; font-weight: 500;"">{reservation.StartTime:HH:mm}</p>
                                    </td>
                                    <td style=""padding: 25px; width: 50%;"">
                                        <p style=""margin: 0 0 8px 0; color: #64748b; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;"">END TIME</p>
                                        <p style=""margin: 0 0 4px 0; color: #0f172a; font-size: 18px; font-weight: 700;"">{reservation.EndTime:MMM dd}</p>
                                        <p style=""margin: 0; color: #475569; font-size: 14px; font-weight: 500;"">{reservation.EndTime:HH:mm}</p>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan=""2"" style=""padding: 20px 25px; background-color: #1e293b; text-align: center;"">
                                        <p style=""margin: 0 0 6px 0; color: #cbd5e1; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;"">DURATION</p>
                                        <p style=""margin: 0; color: #ffffff; font-size: 22px; font-weight: 700;"">{durationText}</p>
                                    </td>
                                </tr>
                            </table>



                            <!-- Late Exit Warning -->
                            <div style=""background-color: #fff1f2; border: 2px solid #fecaca; padding: 22px 26px; border-radius:8px;        margin-bottom:30px;"">
                                <p style=""margin: 0 0 10px 0; color: #b91c1c; font-size: 15px; font-weight: 800; text-transform:       uppercase;        letter-       spacing:      0.5px;"">
                                    ⏰ Late Exit Policy
                                </p>
                            
                                <p style=""margin: 0; color: #7f1d1d; font-size: 14px; line-height: 1.6; font-weight: 500;"">
                                    If you do not exit the parking spot by the scheduled end time,
                                    <strong>the parking fee will be automatically doubled</strong>.
                                    Please ensure timely departure to avoid additional charges.
                                </p>
                            </div>


                            

                            <!-- Price Box -->
                            <div style=""background: linear-gradient(135deg, #1e293b 0%, #334155 100%); padding: 30px; border-radius: 8px; text-align: center; margin-bottom: 30px;"">
                                <p style=""margin: 0 0 10px 0; color: #94a3b8; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 1px;"">TOTAL AMOUNT</p>
                                <p style=""margin: 0; color: #ffffff; font-size: 42px; font-weight: 800; letter-spacing: -1px;"">${reservation.Price:F2}</p>
                            </div>
                            
                            <!-- Payment Status -->
                            <div style=""background-color: #fef3c7; border: 2px solid {paidColor}; padding: 18px 24px; border-radius: 8px; margin-bottom: 30px; text-align: center;"">
                                <p style=""margin: 0; color: {paidColor}; font-size: 15px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;"">
                                    {paidIcon} PAYMENT: {(reservation.IsPaid ? "COMPLETED" : "PENDING")}
                                </p>
                            </div>
                            
                            <!-- Info Section -->
                            <div style=""background-color: #eff6ff; border: 1px solid #bfdbfe; padding: 24px; border-radius: 8px; margin-bottom: 35px;"">
                                <p style=""margin: 0 0 16px 0; color: #1e40af; font-size: 15px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;"">
                                    ⚠️ IMPORTANT INFORMATION
                                </p>
                                <table role=""presentation"" style=""width: 100%; border-collapse: collapse;"">
                                    <tr>
                                        <td style=""padding: 8px 0; color: #1e3a8a; font-size: 14px; line-height: 1.6;"">
                                            • Arrive on time for your reservation
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style=""padding: 8px 0; color: #1e3a8a; font-size: 14px; line-height: 1.6;"">
                                            • Have your vehicle registration ready
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style=""padding: 8px 0; color: #1e3a8a; font-size: 14px; line-height: 1.6;"">
                                            • Contact support for changes or cancellations
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            
                            <p style=""margin: 0 0 25px 0; color: #64748b; font-size: 14px; line-height: 1.7;"">
                                Questions? Our support team is available 24/7 to assist you.
                            </p>
                            
                            <p style=""margin: 0; color: #0f172a; font-size: 15px; font-weight: 600;"">
                                Best regards,<br>
                                <span style=""color: #06b6d4;"">ParkHere Team</span>
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style=""background-color: #1e293b; padding: 35px 40px; text-align: center;"">
                            <p style=""margin: 0 0 10px 0; color: #94a3b8; font-size: 12px; font-weight: 500;"">
                                © {DateTime.Now.Year} ParkHere. All rights reserved.
                            </p>
                            <p style=""margin: 0; color: #64748b; font-size: 11px;"">
                                Automated email - Please do not reply
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
        }
    }
}
