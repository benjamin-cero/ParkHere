import 'package:http/http.dart' as http;
import 'package:parkhere_mobile/providers/base_provider.dart';

class ParkingSessionProvider extends BaseProvider<dynamic> {
  ParkingSessionProvider() : super("ParkingSession");

  Future<void> registerArrival(int reservationId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/register-arrival/$reservationId";
    var response = await http.post(Uri.parse(url), headers: createHeaders());
    
    if (response.statusCode != 200) {
      throw Exception("Failed to register arrival");
    }
  }
  
  Future<void> setActualEndTime(int reservationId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/set-end-time/$reservationId";
    var response = await http.post(Uri.parse(url), headers: createHeaders());
    
    if (response.statusCode != 200) {
      throw Exception("Failed to exit parking");
    }
  }

  @override
  dynamic fromJson(data) {
    return data;
  }
}
