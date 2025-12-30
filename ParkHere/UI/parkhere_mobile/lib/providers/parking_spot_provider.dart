import 'package:parkhere_mobile/model/parking_spot.dart';
import 'package:parkhere_mobile/providers/base_provider.dart';

class ParkingSpotProvider extends BaseProvider<ParkingSpot> {
  ParkingSpotProvider() : super("ParkingSpot");

  @override
  ParkingSpot fromJson(data) {
    return ParkingSpot.fromJson(data);
  }
}
