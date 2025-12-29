// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingSession _$ParkingSessionFromJson(Map<String, dynamic> json) =>
    ParkingSession(
      id: (json['id'] as num?)?.toInt() ?? 0,
      parkingReservationId:
          (json['parkingReservationId'] as num?)?.toInt() ?? 0,
      actualStartTime: json['actualStartTime'] == null
          ? null
          : DateTime.parse(json['actualStartTime'] as String),
      arrivalTime: json['arrivalTime'] == null
          ? null
          : DateTime.parse(json['arrivalTime'] as String),
      actualEndTime: json['actualEndTime'] == null
          ? null
          : DateTime.parse(json['actualEndTime'] as String),
      extraMinutes: (json['extraMinutes'] as num?)?.toInt(),
      extraCharge: (json['extraCharge'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      parkingReservation: ParkingReservation.fromJson(
        json['parkingReservation'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ParkingSessionToJson(ParkingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parkingReservationId': instance.parkingReservationId,
      'actualStartTime': instance.actualStartTime?.toIso8601String(),
      'arrivalTime': instance.arrivalTime?.toIso8601String(),
      'actualEndTime': instance.actualEndTime?.toIso8601String(),
      'extraMinutes': instance.extraMinutes,
      'extraCharge': instance.extraCharge,
      'createdAt': instance.createdAt.toIso8601String(),
      'parkingReservation': instance.parkingReservation,
    };
