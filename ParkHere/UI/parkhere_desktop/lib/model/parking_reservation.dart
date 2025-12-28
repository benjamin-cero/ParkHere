import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'vehicle.dart';
import 'parking_spot.dart';
import 'parking_session.dart';

part 'parking_reservation.g.dart';

@JsonSerializable()
class ParkingReservation {
  final int id;
  final int userId;
  final int vehicleId;
  final int parkingSpotId;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final bool isPaid;
  final DateTime createdAt;

  // Navigation properties
  final User? user;
  final Vehicle? vehicle;
  final ParkingSpot? parkingSpot;
  final ParkingSession? parkingSession;

  ParkingReservation({
    this.id = 0,
    this.userId = 0,
    this.vehicleId = 0,
    this.parkingSpotId = 0,
    required this.startTime,
    required this.endTime,
    this.price = 0,
    this.isPaid = false,
    required this.createdAt,
    this.user,
    this.vehicle,
    this.parkingSpot,
    this.parkingSession,
  });

  factory ParkingReservation.fromJson(Map<String, dynamic> json) => _$ParkingReservationFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingReservationToJson(this);
}
