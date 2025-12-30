// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
      id: (json['id'] as num?)?.toInt() ?? 0,
      licensePlate: json['licensePlate'] as String? ?? '',
      name: json['name'] as String? ?? '',
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      'id': instance.id,
      'licensePlate': instance.licensePlate,
      'name': instance.name,
      'userId': instance.userId,
      'isActive': instance.isActive,
    };
