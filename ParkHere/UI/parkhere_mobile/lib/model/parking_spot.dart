import 'package:json_annotation/json_annotation.dart';

part 'parking_spot.g.dart';

@JsonSerializable()
class ParkingSpot {
  final int id;
  final String name;
  final int parkingSpotTypeId;
  final String parkingSpotTypeName;
  final int parkingSectorId;
  final String parkingSectorName;
  final bool isOccupied;
  final bool isActive;

  ParkingSpot({
    this.id = 0,
    this.name = '',
    this.parkingSpotTypeId = 0,
    this.parkingSpotTypeName = '',
    this.parkingSectorId = 0,
    this.parkingSectorName = '',
    this.isOccupied = false,
    this.isActive = true,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) => _$ParkingSpotFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingSpotToJson(this);
}
