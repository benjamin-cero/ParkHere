using System.Net;
using System.Net.Mail;
using ParkHere.Subscriber.Interfaces;

namespace ParkHere.Subscriber.Services
{
    public class EmailSenderService : IEmailSenderService
    {
        private readonly string _gmailMail = "pakrhere.send@gmail.com";
        private readonly string _gmailPass = "rpth yrzi pnhk vkjc";

        public Task SendEmailAsync(string email, string subject, string message)
        {
            var client = new SmtpClient("smtp.gmail.com", 587)
            {
                EnableSsl = true,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(_gmailMail, _gmailPass)
            };

            var mailMessage = new MailMessage(from: _gmailMail, to: email, subject, message)
            {
                IsBodyHtml = true
            };

            return client.SendMailAsync(mailMessage);
        }
    }
}