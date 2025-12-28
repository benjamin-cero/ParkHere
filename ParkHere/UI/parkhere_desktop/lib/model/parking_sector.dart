import 'package:json_annotation/json_annotation.dart';

part 'parking_sector.g.dart';

@JsonSerializable()
class ParkingSector {
  final int id;
  final int floorNumber;
  final String name;
  final bool isActive;

  ParkingSector({
    this.id = 0,
    this.floorNumber = 0,
    this.name = '',
    this.isActive = true,
  });

  factory ParkingSector.fromJson(Map<String, dynamic> json) => _$ParkingSectorFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingSectorToJson(this);
}
