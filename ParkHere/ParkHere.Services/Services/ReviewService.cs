using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using ParkHere.Services.Database;
using ParkHere.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace ParkHere.Services.Services
{
    public class ReviewService : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        public ReviewService(ParkHereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearchObject search)
        {
            query = query.Include(x => x.User)
                         .Include(x => x.ParkingReservation);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId);

            if (search.ReservationId.HasValue)
                query = query.Where(x => x.ReservationId == search.ReservationId);

            if (search.Rating.HasValue)
                query = query.Where(x => x.Rating == search.Rating);

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.User.FirstName.Contains(search.Name) || x.User.LastName.Contains(search.Name));
            }

            return query;
        }
    }
}
