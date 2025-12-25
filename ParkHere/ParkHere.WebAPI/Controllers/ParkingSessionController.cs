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

        [HttpPost("set-start-time")]
        public async Task<IActionResult> SetActualStartTime([FromBody] SetStartTimeRequest request)
        {
            try
            {
                var result = await _service.SetActualStartTimeAsync(request.ReservationId, request.ActualStartTime);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("set-end-time")]
        public async Task<IActionResult> SetActualEndTime([FromBody] SetEndTimeRequest request)
        {
            try
            {
                var result = await _service.SetActualEndTimeAsync(request.ReservationId, request.ActualEndTime);
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