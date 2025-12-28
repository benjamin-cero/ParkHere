import 'package:parkhere_desktop/model/parking_sector.dart';
import 'package:parkhere_desktop/providers/base_provider.dart';

class ParkingSectorProvider extends BaseProvider<ParkingSector> {
  ParkingSectorProvider() : super("ParkingSector");

  @override
  ParkingSector fromJson(dynamic json) {
    return ParkingSector.fromJson(json);
  }
}
