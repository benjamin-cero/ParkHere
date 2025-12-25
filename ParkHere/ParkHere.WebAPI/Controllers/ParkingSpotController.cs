using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ParkHere.WebAPI.Controllers
{
    public class ParkingSpotController : BaseCRUDController<ParkingSpotResponse, ParkingSpotSearchObject, ParkingSpotInsertRequest, ParkingSpotUpdateRequest>
    {
        public ParkingSpotController(IParkingSpotService service) : base(service)
        {
        }

     
    }
}