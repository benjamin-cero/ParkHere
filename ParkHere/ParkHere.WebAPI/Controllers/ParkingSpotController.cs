using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace ParkHere.WebAPI.Controllers
{
    public class ParkingSpotController : BaseCRUDController<ParkingSpotResponse, ParkingSpotSearchObject, ParkingSpotInsertRequest, ParkingSpotUpdateRequest>
    {
        public ParkingSpotController(IParkingSpotService service) : base(service)
        {
        }

        [HttpGet("Recommend")]
        public async Task<ParkingSpotResponse?> Recommend()
        {
            var userIdString = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdString)) return null;

            return await (_service as IParkingSpotService).Recommend(int.Parse(userIdString));
        }
    }
}