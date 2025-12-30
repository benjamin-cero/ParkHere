import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  final int id;
  final String licensePlate;
  final String name;
  final int userId;
  final bool isActive;

  Vehicle({
    this.id = 0,
    this.licensePlate = '',
    this.name = '',
    this.userId = 0,
    this.isActive = true,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}
