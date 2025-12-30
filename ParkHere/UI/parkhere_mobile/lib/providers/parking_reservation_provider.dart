import 'package:parkhere_mobile/model/parking_reservation.dart';
import 'package:parkhere_mobile/providers/base_provider.dart';

class ParkingReservationProvider extends BaseProvider<ParkingReservation> {
  ParkingReservationProvider() : super("ParkingReservation");

  @override
  ParkingReservation fromJson(data) {
    return ParkingReservation.fromJson(data);
  }
}
