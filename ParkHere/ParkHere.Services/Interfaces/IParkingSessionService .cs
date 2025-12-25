using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;

namespace ParkHere.Services.Interfaces
{
    public interface IParkingSessionService : ICRUDService<ParkingSessionResponse, ParkingSessionSearchObject, ParkingSessionInsertRequest, ParkingSessionUpdateRequest>
    {
    }
}