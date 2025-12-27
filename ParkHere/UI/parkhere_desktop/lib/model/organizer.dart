import 'package:json_annotation/json_annotation.dart';

part 'organizer.g.dart';

@JsonSerializable()
class Organizer {
  final int id;
  final String name;
  final String? contactInfo;
  final bool isActive;

  const Organizer({
    this.id = 0,
    this.name = '',
    this.contactInfo,
    this.isActive = true,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) =>
      _$OrganizerFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizerToJson(this);
}
