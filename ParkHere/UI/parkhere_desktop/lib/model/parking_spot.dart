import 'package:json_annotation/json_annotation.dart';

part 'parking_spot.g.dart';

@JsonSerializable()
class ParkingSpot {
  final int id;
  final String spotCode;
  final int parkingWingId;
  final int parkingSpotTypeId;
  final bool isOccupied;
  final bool isActive;

  ParkingSpot({
    this.id = 0,
    this.spotCode = '',
    this.parkingWingId = 0,
    this.parkingSpotTypeId = 0,
    this.isOccupied = false,
    this.isActive = true,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) => _$ParkingSpotFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingSpotToJson(this);
}
