// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_spot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingSpot _$ParkingSpotFromJson(Map<String, dynamic> json) => ParkingSpot(
  id: (json['id'] as num?)?.toInt() ?? 0,
  spotCode: json['spotCode'] as String? ?? '',
  parkingWingId: (json['parkingWingId'] as num?)?.toInt() ?? 0,
  parkingSpotTypeId: (json['parkingSpotTypeId'] as num?)?.toInt() ?? 0,
  isOccupied: json['isOccupied'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ParkingSpotToJson(ParkingSpot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'spotCode': instance.spotCode,
      'parkingWingId': instance.parkingWingId,
      'parkingSpotTypeId': instance.parkingSpotTypeId,
      'isOccupied': instance.isOccupied,
      'isActive': instance.isActive,
    };
