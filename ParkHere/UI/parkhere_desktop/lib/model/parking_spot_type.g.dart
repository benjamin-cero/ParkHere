// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_spot_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingSpotType _$ParkingSpotTypeFromJson(Map<String, dynamic> json) =>
    ParkingSpotType(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      priceMultiplier: (json['priceMultiplier'] as num?)?.toDouble() ?? 1.0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ParkingSpotTypeToJson(ParkingSpotType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'priceMultiplier': instance.priceMultiplier,
      'isActive': instance.isActive,
    };
