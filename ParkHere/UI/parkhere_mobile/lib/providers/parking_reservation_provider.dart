import 'package:http/http.dart' as http;
import 'package:parkhere_mobile/model/parking_reservation.dart';
import 'package:parkhere_mobile/providers/base_provider.dart';

class ParkingReservationProvider extends BaseProvider<ParkingReservation> {
  ParkingReservationProvider() : super("ParkingReservation");

  @override
  ParkingReservation fromJson(data) {
    return ParkingReservation.fromJson(data);
  }

  Future<double> getDebt(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/GetDebt/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      return double.parse(response.body);
    } else {
      throw Exception("Failed to fetch debt");
    }
  }
}
