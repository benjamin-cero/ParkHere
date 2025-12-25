using ParkHere.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using ParkHere.Model.Responses;
using ParkHere.Model.Requests;
using ParkHere.Model.SearchObjects;

namespace ParkHere.Services.Interfaces
{
    public interface IService<T, TSearch> where T : class where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> GetAsync(TSearch search);
        Task<T?> GetByIdAsync(int id);
    }
}