using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ParkHere.WebAPI.Controllers
{
    public class ParkingWingController : BaseCRUDController<ParkingWingResponse, ParkingWingSearchObject, ParkingWingInsertRequest, ParkingWingUpdateRequest>
    {
        public ParkingWingController(IParkingWingService service) : base(service)
        {
        }

     
    }
}