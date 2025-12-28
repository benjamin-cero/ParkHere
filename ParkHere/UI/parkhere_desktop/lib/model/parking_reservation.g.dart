// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingReservation _$ParkingReservationFromJson(Map<String, dynamic> json) =>
    ParkingReservation(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      vehicleId: (json['vehicleId'] as num?)?.toInt() ?? 0,
      parkingSpotId: (json['parkingSpotId'] as num?)?.toInt() ?? 0,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isPaid: json['isPaid'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      vehicle: json['vehicle'] == null
          ? null
          : Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>),
      parkingSpot: json['parkingSpot'] == null
          ? null
          : ParkingSpot.fromJson(json['parkingSpot'] as Map<String, dynamic>),
      parkingSession: json['parkingSession'] == null
          ? null
          : ParkingSession.fromJson(
              json['parkingSession'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ParkingReservationToJson(ParkingReservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'vehicleId': instance.vehicleId,
      'parkingSpotId': instance.parkingSpotId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'price': instance.price,
      'isPaid': instance.isPaid,
      'createdAt': instance.createdAt.toIso8601String(),
      'user': instance.user,
      'vehicle': instance.vehicle,
      'parkingSpot': instance.parkingSpot,
      'parkingSession': instance.parkingSession,
    };
