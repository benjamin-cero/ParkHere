// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_wing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingWing _$ParkingWingFromJson(Map<String, dynamic> json) => ParkingWing(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  parkingSectorId: (json['parkingSectorId'] as num?)?.toInt() ?? 0,
  parkingSectorName: json['parkingSectorName'] as String?,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ParkingWingToJson(ParkingWing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parkingSectorId': instance.parkingSectorId,
      'parkingSectorName': instance.parkingSectorName,
      'isActive': instance.isActive,
    };
