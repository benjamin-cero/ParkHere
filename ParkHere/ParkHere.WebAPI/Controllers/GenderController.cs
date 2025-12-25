using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ParkHere.WebAPI.Controllers
{
    public class GenderController : BaseCRUDController<GenderResponse, GenderSearchObject, GenderUpsertRequest, GenderUpsertRequest>
    {
        public GenderController(IGenderService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<GenderResponse>> Get([FromQuery] GenderSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<GenderResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}