import 'package:parkhere_mobile/model/parking_sector.dart';
import 'package:parkhere_mobile/providers/base_provider.dart';

class ParkingSectorProvider extends BaseProvider<ParkingSector> {
  ParkingSectorProvider() : super("ParkingSector");

  @override
  ParkingSector fromJson(data) {
    return ParkingSector.fromJson(data);
  }
}
