class ParkingSector {
  final int id;
  final String name;
  final int floorNumber;
  final bool isActive;

  ParkingSector({
    this.id = 0,
    this.name = '',
    this.floorNumber = 0,
    this.isActive = true,
  });

  factory ParkingSector.fromJson(Map<String, dynamic> json) => ParkingSector(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    floorNumber: (json['floorNumber'] as num?)?.toInt() ?? 0,
    isActive: json['isActive'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'floorNumber': floorNumber,
    'isActive': isActive,
  };
}
