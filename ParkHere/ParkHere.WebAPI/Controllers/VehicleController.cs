using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ParkHere.WebAPI.Controllers
{
    public class VehicleController : BaseCRUDController<VehicleResponse, VehicleSearchObject, VehicleInsertRequest, VehicleUpdateRequest>
    {
        public VehicleController(IVehicleService service) : base(service)
        {
        }

     
    }
}