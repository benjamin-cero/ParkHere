// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_sector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingSector _$ParkingSectorFromJson(Map<String, dynamic> json) =>
    ParkingSector(
      id: (json['id'] as num?)?.toInt() ?? 0,
      floorNumber: (json['floorNumber'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ParkingSectorToJson(ParkingSector instance) =>
    <String, dynamic>{
      'id': instance.id,
      'floorNumber': instance.floorNumber,
      'name': instance.name,
      'isActive': instance.isActive,
    };
