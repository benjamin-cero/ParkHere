using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ParkHere.WebAPI.Controllers
{
    public class ParkingReservationController : BaseCRUDController<ParkingReservationResponse, ParkingReservationSearchObject, ParkingReservationInsertRequest, ParkingReservationUpdateRequest>
    {
        public ParkingReservationController(IParkingReservationService service) : base(service)
        {
        }

     
    }
}