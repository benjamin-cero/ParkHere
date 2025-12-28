import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  final int id;
  final String licensePlate;
  final String model;
  final String? color;
  final int userId;

  Vehicle({
    this.id = 0,
    this.licensePlate = '',
    this.model = '',
    this.color,
    this.userId = 0,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}
