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
  final int parkingWingId;
  final String parkingWingName;
  final bool isOccupied;
  final bool isActive;

  ParkingSpot({
    this.id = 0,
    this.name = '',
    this.parkingSpotTypeId = 0,
    this.parkingSpotTypeName = '',
    this.parkingSectorId = 0,
    this.parkingSectorName = '',
    this.parkingWingId = 0,
    this.parkingWingName = '',
    this.isOccupied = false,
    this.isActive = true,
  });



  factory ParkingSpot.fromJson(Map<String, dynamic> json) => ParkingSpot(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      parkingSpotTypeId: (json['parkingSpotTypeId'] as num?)?.toInt() ?? 0,
      parkingSpotTypeName: json['parkingSpotTypeName'] as String? ?? '',
      parkingSectorId: (json['parkingSectorId'] as num?)?.toInt() ?? 0,
      parkingSectorName: json['parkingSectorName'] as String? ?? '',
      parkingWingId: (json['parkingWingId'] as num?)?.toInt() ?? 0,
      parkingWingName: json['parkingWingName'] as String? ?? '',
      isOccupied: json['isOccupied'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );

  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': id,
      'name': name,
      'parkingSpotTypeId': parkingSpotTypeId,
      'parkingSpotTypeName': parkingSpotTypeName,
      'parkingSectorId': parkingSectorId,
      'parkingSectorName': parkingSectorName,
      'parkingWingId': parkingWingId,
      'parkingWingName': parkingWingName,
      'isOccupied': isOccupied,
      'isActive': isActive,
    };
}
