import 'dart:convert';
import 'package:parkhere_desktop/model/parking_session.dart';
import 'package:parkhere_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class ParkingSessionProvider extends BaseProvider<ParkingSession> {
  ParkingSessionProvider() : super("ParkingSession");

  @override
  ParkingSession fromJson(dynamic json) {
    return ParkingSession.fromJson(json);
  }

  Future<ParkingSession> startSession(int reservationId) async {
    var url = "${BaseProvider.baseUrl}ParkingSession/set-start-time";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var request = {
      "reservationId": reservationId,
      "actualStartTime": DateTime.now().toIso8601String(),
    };

    var response = await http.post(uri, headers: headers, body: jsonEncode(request));

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to start session");
    }
  }
}
