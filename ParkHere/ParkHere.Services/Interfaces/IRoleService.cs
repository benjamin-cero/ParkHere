using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;

namespace ParkHere.Services.Interfaces
{
    public interface IRoleService : ICRUDService<RoleResponse, RoleSearchObject, RoleUpsertRequest, RoleUpsertRequest>
    {
    }
}