import 'package:json_annotation/json_annotation.dart';

part 'ticket_type.g.dart';

@JsonSerializable()
class TicketType {
  final int id;
  final String name;
  final String? description;
  final double priceMultiplier;
  final bool isActive;

  const TicketType({
    this.id = 0,
    this.name = '',
    this.description,
    this.priceMultiplier = 1.0,
    this.isActive = true,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) => _$TicketTypeFromJson(json);
  Map<String, dynamic> toJson() => _$TicketTypeToJson(this);
}
