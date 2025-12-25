using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;

namespace ParkHere.Services.Interfaces
{
    public interface IParkingSpotService : ICRUDService<ParkingSpotResponse, ParkingSpotSearchObject, ParkingSpotInsertRequest, ParkingSpotUpdateRequest>
    {
    }
}