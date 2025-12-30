// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_spot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingSpot _$ParkingSpotFromJson(Map<String, dynamic> json) => ParkingSpot(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      parkingSpotTypeId: (json['parkingSpotTypeId'] as num?)?.toInt() ?? 0,
      parkingSpotTypeName: json['parkingSpotTypeName'] as String? ?? '',
      parkingSectorId: (json['parkingSectorId'] as num?)?.toInt() ?? 0,
      parkingSectorName: json['parkingSectorName'] as String? ?? '',
      isOccupied: json['isOccupied'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ParkingSpotToJson(ParkingSpot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parkingSpotTypeId': instance.parkingSpotTypeId,
      'parkingSpotTypeName': instance.parkingSpotTypeName,
      'parkingSectorId': instance.parkingSectorId,
      'parkingSectorName': instance.parkingSectorName,
      'isOccupied': instance.isOccupied,
      'isActive': instance.isActive,
    };
