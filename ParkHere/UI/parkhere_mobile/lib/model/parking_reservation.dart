import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'vehicle.dart';
import 'parking_spot.dart';

part 'parking_reservation.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal)
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
  final DateTime? arrivalTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final double? extraCharge;
  final double? includedDebt;

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
    this.arrivalTime,
    this.actualStartTime,
    this.actualEndTime,
    this.extraCharge,
    this.includedDebt,
  });

  factory ParkingReservation.fromJson(Map<String, dynamic> json) {
      return ParkingReservation(
          id: (json['id'] as num?)?.toInt() ?? (json['Id'] as num?)?.toInt() ?? 0,
          userId: (json['userId'] as num?)?.toInt() ?? (json['UserId'] as num?)?.toInt() ?? 0,
          vehicleId: (json['vehicleId'] as num?)?.toInt() ?? (json['VehicleId'] as num?)?.toInt() ?? 0,
          parkingSpotId: (json['parkingSpotId'] as num?)?.toInt() ?? (json['ParkingSpotId'] as num?)?.toInt() ?? 0,
          startTime: DateTime.parse(json['startTime'] ?? json['StartTime']),
          endTime: DateTime.parse(json['endTime'] ?? json['EndTime']),
          price: (json['price'] as num?)?.toDouble() ?? (json['Price'] as num?)?.toDouble() ?? 0.0,
          isPaid: json['isPaid'] as bool? ?? json['IsPaid'] as bool? ?? false,
          createdAt: DateTime.parse(json['createdAt'] ?? json['CreatedAt'] ?? DateTime.now().toIso8601String()),
          
          user: (json['user'] != null) ? User.fromJson(json['user']) : (json['User'] != null ? User.fromJson(json['User']) : null),
          vehicle: (json['vehicle'] != null) ? Vehicle.fromJson(json['vehicle']) : (json['Vehicle'] != null ? Vehicle.fromJson(json['Vehicle']) : null),
          parkingSpot: (json['parkingSpot'] != null) ? ParkingSpot.fromJson(json['parkingSpot']) : (json['ParkingSpot'] != null ? ParkingSpot.fromJson(json['ParkingSpot']) : null),
          
          arrivalTime: (json['arrivalTime'] ?? json['ArrivalTime']) != null ? DateTime.parse(json['arrivalTime'] ?? json['ArrivalTime']) : null,
          actualStartTime: (json['actualStartTime'] ?? json['ActualStartTime']) != null ? DateTime.parse(json['actualStartTime'] ?? json['ActualStartTime']) : null,
          actualEndTime: (json['actualEndTime'] ?? json['ActualEndTime']) != null ? DateTime.parse(json['actualEndTime'] ?? json['ActualEndTime']) : null,
          extraCharge: (json['extraCharge'] as num?)?.toDouble() ?? (json['ExtraCharge'] as num?)?.toDouble(),
          includedDebt: (json['includedDebt'] as num?)?.toDouble() ?? (json['IncludedDebt'] as num?)?.toDouble(),
      );
  }

  Map<String, dynamic> toJson() => _$ParkingReservationToJson(this);
}
