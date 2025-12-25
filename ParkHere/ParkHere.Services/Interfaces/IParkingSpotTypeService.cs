using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;

namespace ParkHere.Services.Interfaces
{
    public interface IParkingSpotTypeService : ICRUDService<ParkingSpotTypeResponse, ParkingSpotTypeSearchObject, ParkingSpotTypeUpsertRequest, ParkingSpotTypeUpsertRequest>
    {
    }
}