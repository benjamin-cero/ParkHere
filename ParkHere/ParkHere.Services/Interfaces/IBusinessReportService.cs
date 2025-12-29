using ParkHere.Model.Responses;
using System.Threading.Tasks;

namespace ParkHere.Services.Interfaces
{
    public interface IBusinessReportService
    {
        Task<BusinessReportResponse> GetBusinessReport();
    }
}
