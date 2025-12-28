import 'package:parkhere_desktop/model/parking_reservation.dart';
import 'package:parkhere_desktop/providers/base_provider.dart';

class ParkingReservationProvider extends BaseProvider<ParkingReservation> {
  ParkingReservationProvider() : super("ParkingReservation");

  @override
  ParkingReservation fromJson(dynamic json) {
    return ParkingReservation.fromJson(json);
  }
}
