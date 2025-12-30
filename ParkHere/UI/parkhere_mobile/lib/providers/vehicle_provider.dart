import 'package:parkhere_mobile/model/vehicle.dart';
import 'package:parkhere_mobile/providers/base_provider.dart';

class VehicleProvider extends BaseProvider<Vehicle> {
  VehicleProvider() : super("Vehicle");

  @override
  Vehicle fromJson(data) {
    return Vehicle.fromJson(data);
  }
}
