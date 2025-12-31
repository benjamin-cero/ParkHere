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



  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
      // Handle nested or flat structure
      final wing = json['parkingWing'];
      final sector = wing?['parkingSector']; // In case it's nested
      
      return ParkingSpot(
          id: (json['id'] as num?)?.toInt() ?? 0,
          name: json['spotCode'] as String? ?? json['name'] as String? ?? '',
          parkingSpotTypeId: (json['parkingSpotTypeId'] as num?)?.toInt() ?? 0,
          parkingSpotTypeName: json['parkingSpotType']?['name'] as String? ?? json['parkingSpotTypeName'] as String? ?? '',
          
          // Robust Sector/Wing parsing
          parkingSectorId: (sector?['id'] as num?)?.toInt() ?? 
                           (wing?['parkingSectorId'] as num?)?.toInt() ?? 
                           (json['parkingSectorId'] as num?)?.toInt() ?? 0,
                           
          parkingSectorName: (sector?['name'] as String?) ?? 
                             (wing?['parkingSectorName'] as String?) ?? 
                             (json['parkingSectorName'] as String?) ?? '',
                             
          parkingWingId: (wing?['id'] as num?)?.toInt() ?? 
                         (json['parkingWingId'] as num?)?.toInt() ?? 0,
                         
          parkingWingName: (wing?['name'] as String?) ?? 
                           (json['parkingWingName'] as String?) ?? '',
                           
          isOccupied: json['isOccupied'] as bool? ?? false,
          isActive: json['isActive'] as bool? ?? true,
        );
  }

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
