using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;

namespace ParkHere.Services.Interfaces
{
    public interface IParkingWingService : ICRUDService<ParkingWingResponse, ParkingWingSearchObject, ParkingWingInsertRequest, ParkingWingUpdateRequest>
    {
    }
}