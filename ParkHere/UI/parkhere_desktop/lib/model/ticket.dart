import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  final int id;
  final int festivalId;
  final String festivalTitle;
  final int userId;
  final String username;
  final String userFullName;
  final int ticketTypeId;
  final String ticketTypeName;
  final double finalPrice;
  final String qrCodeData;
  final String textCode;
  final bool isRedeemed;
  final DateTime createdAt;
  final DateTime? redeemedAt;

  const Ticket({
    this.id = 0,
    this.festivalId = 0,
    this.festivalTitle = '',
    this.userId = 0,
    this.username = '',
    this.userFullName = '',
    this.ticketTypeId = 0,
    this.ticketTypeName = '',
    this.finalPrice = 0.0,
    this.qrCodeData = '',
    this.textCode = '',
    this.isRedeemed = false,
    required this.createdAt,
    this.redeemedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
  Map<String, dynamic> toJson() => _$TicketToJson(this);
}
