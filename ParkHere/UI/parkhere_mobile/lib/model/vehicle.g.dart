// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
      id: (json['id'] as num?)?.toInt() ?? 0,
      licensePlate: json['licensePlate'] as String? ?? '',
      model: json['model'] as String? ?? '',
      color: json['color'] as String?,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      'id': instance.id,
      'licensePlate': instance.licensePlate,
      'model': instance.model,
      'color': instance.color,
      'userId': instance.userId,
    };
