using ParkHere.Model.Requests;
using ParkHere.Model.Responses;
using ParkHere.Model.SearchObjects;
using System;
using System.Threading.Tasks;

namespace ParkHere.Services.Interfaces
{
    public interface IParkingSessionService : ICRUDService<ParkingSessionResponse, ParkingSessionSearchObject, ParkingSessionInsertRequest, ParkingSessionUpdateRequest>
    {
        Task<ParkingSessionResponse> RegisterArrivalAsync(int reservationId);
        Task<ParkingSessionResponse> SetActualStartTimeAsync(int reservationId);
        Task<ParkingSessionResponse> SetActualEndTimeAsync(int reservationId, DateTime actualEndTime);
        Task MarkReservationAsPaidAsync(int reservationId);
    }
}