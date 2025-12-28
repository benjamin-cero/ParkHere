import 'package:json_annotation/json_annotation.dart';

part 'parking_wing.g.dart';

@JsonSerializable()
class ParkingWing {
  final int id;
  final String name;
  final int parkingSectorId;
  final String? parkingSectorName;
  final bool isActive;

  ParkingWing({
    this.id = 0,
    this.name = '',
    this.parkingSectorId = 0,
    this.parkingSectorName,
    this.isActive = true,
  });

  factory ParkingWing.fromJson(Map<String, dynamic> json) => _$ParkingWingFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingWingToJson(this);
}
