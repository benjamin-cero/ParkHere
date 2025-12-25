using ParkHere.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using ParkHere.Model.Responses;
using ParkHere.Model.Requests;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Services;

namespace ParkHere.Services.Interfaces
{
    public interface IUserService : IService<UserResponse, UserSearchObject>
    {
        Task<UserResponse?> AuthenticateAsync(UserLoginRequest request);
        Task<UserResponse> CreateAsync(UserUpsertRequest request);
        Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest request);
        Task<bool> DeleteAsync(int id);
    }
}