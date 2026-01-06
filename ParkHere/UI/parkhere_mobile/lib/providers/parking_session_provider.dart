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
  
  Future<void> setActualEndTime(int reservationId, {DateTime? actualEndTime}) async {
    var url = "${BaseProvider.baseUrl}$endpoint/set-end-time/$reservationId";
    String body = actualEndTime != null ? '"${actualEndTime.toIso8601String()}"' : "";
    
    var response = await http.post(
      Uri.parse(url), 
      headers: {
        ...createHeaders(),
        "Content-Type": "application/json",
      },
      body: body,
    );
    
    if (response.statusCode != 200) {
      throw Exception("Failed to exit parking");
    }
  }

  Future<void> markAsPaid(int reservationId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/mark-paid/$reservationId";
    var response = await http.post(Uri.parse(url), headers: createHeaders());
    
    if (response.statusCode != 200) {
      throw Exception("Failed to mark reservation as paid");
    }
  }

  @override
  dynamic fromJson(data) {
    return data;
  }
}
