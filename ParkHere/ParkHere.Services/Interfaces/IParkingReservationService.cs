using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;

namespace ParkHere.Services.Interfaces
{
    public interface IParkingReservationService : ICRUDService<ParkingReservationResponse, ParkingReservationSearchObject, ParkingReservationInsertRequest, ParkingReservationUpdateRequest>
    {
    }
}