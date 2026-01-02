using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace ParkHere.WebAPI.Controllers
{
    public class ParkingSessionController : BaseCRUDController<ParkingSessionResponse, ParkingSessionSearchObject, ParkingSessionInsertRequest, ParkingSessionUpdateRequest>
    {
        private readonly IParkingSessionService _service;

        public ParkingSessionController(IParkingSessionService service)
            : base(service)
        {
            _service = service;
        }

        [HttpPost("register-arrival/{reservationId}")]
        public async Task<IActionResult> RegisterArrival(int reservationId)
        {
            try
            {
                var result = await _service.RegisterArrivalAsync(reservationId);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("set-start-time/{reservationId}")]
        public async Task<IActionResult> SetActualStartTime(int reservationId)
        {
            try
            {
                var result = await _service.SetActualStartTimeAsync(reservationId);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("set-end-time/{reservationId}")]
        public async Task<IActionResult> SetActualEndTime(int reservationId)
        {
            try
            {
                var result = await _service.SetActualEndTimeAsync(reservationId, DateTime.Now);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("mark-paid/{reservationId}")]
        public async Task<IActionResult> MarkReservationAsPaid(int reservationId)
        {
            try
            {
                await _service.MarkReservationAsPaidAsync(reservationId);
                return Ok(new { message = "Reservation marked as paid successfully." });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
     
    }
}