import 'package:json_annotation/json_annotation.dart';
import 'parking_reservation.dart';

part 'parking_session.g.dart';

@JsonSerializable()
class ParkingSession {
  final int id;
  final int parkingReservationId;
  final DateTime? actualStartTime;
  final DateTime? arrivalTime;
  final DateTime? actualEndTime;
  final int? extraMinutes;
  final double? extraCharge;
  final DateTime createdAt;
  final ParkingReservation parkingReservation;

  ParkingSession({
    this.id = 0,
    this.parkingReservationId = 0,
    this.actualStartTime,
    this.arrivalTime,
    this.actualEndTime,
    this.extraMinutes,
    this.extraCharge,
    required this.createdAt,
    required this.parkingReservation,
  });

  factory ParkingSession.fromJson(Map<String, dynamic> json) => _$ParkingSessionFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingSessionToJson(this);
}
