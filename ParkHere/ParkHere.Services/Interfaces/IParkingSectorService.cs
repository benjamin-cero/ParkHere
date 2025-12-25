using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;

namespace ParkHere.Services.Interfaces
{
    public interface IParkingSectorService : ICRUDService<ParkingSectorResponse, ParkingSectorSearchObject, ParkingSectorUpsertRequest, ParkingSectorUpsertRequest>
    {
    }
}