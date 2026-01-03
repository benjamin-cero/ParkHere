import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parkhere_mobile/model/parking_spot.dart';
import 'package:parkhere_mobile/providers/base_provider.dart';

class ParkingSpotProvider extends BaseProvider<ParkingSpot> {
  ParkingSpotProvider() : super("ParkingSpot");

  @override
  ParkingSpot fromJson(data) {
    return ParkingSpot.fromJson(data);
  }

  Future<ParkingSpot?> recommend() async {
    var url = "${BaseProvider.baseUrl}$endpoint/Recommend";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
}
