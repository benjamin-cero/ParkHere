using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ParkHere.Model.Responses;
using ParkHere.Services.Interfaces;
using System.Threading.Tasks;

namespace ParkHere.WebAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class BusinessReportController : ControllerBase
    {
        private readonly IBusinessReportService _service;

        public BusinessReportController(IBusinessReportService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<BusinessReportResponse> Get()
        {
            return await _service.GetBusinessReport();
        }
    }
}
