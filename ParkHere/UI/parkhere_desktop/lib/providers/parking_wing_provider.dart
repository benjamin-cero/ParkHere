import 'package:parkhere_desktop/model/parking_wing.dart';
import 'package:parkhere_desktop/providers/base_provider.dart';

class ParkingWingProvider extends BaseProvider<ParkingWing> {
  ParkingWingProvider() : super("ParkingWing");

  @override
  ParkingWing fromJson(dynamic json) {
    return ParkingWing.fromJson(json);
  }
}
