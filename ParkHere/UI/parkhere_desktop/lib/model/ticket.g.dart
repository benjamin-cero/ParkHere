// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
  id: (json['id'] as num?)?.toInt() ?? 0,
  festivalId: (json['festivalId'] as num?)?.toInt() ?? 0,
  festivalTitle: json['festivalTitle'] as String? ?? '',
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  userFullName: json['userFullName'] as String? ?? '',
  ticketTypeId: (json['ticketTypeId'] as num?)?.toInt() ?? 0,
  ticketTypeName: json['ticketTypeName'] as String? ?? '',
  finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
  qrCodeData: json['qrCodeData'] as String? ?? '',
  textCode: json['textCode'] as String? ?? '',
  isRedeemed: json['isRedeemed'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  redeemedAt: json['redeemedAt'] == null
      ? null
      : DateTime.parse(json['redeemedAt'] as String),
);

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
  'id': instance.id,
  'festivalId': instance.festivalId,
  'festivalTitle': instance.festivalTitle,
  'userId': instance.userId,
  'username': instance.username,
  'userFullName': instance.userFullName,
  'ticketTypeId': instance.ticketTypeId,
  'ticketTypeName': instance.ticketTypeName,
  'finalPrice': instance.finalPrice,
  'qrCodeData': instance.qrCodeData,
  'textCode': instance.textCode,
  'isRedeemed': instance.isRedeemed,
  'createdAt': instance.createdAt.toIso8601String(),
  'redeemedAt': instance.redeemedAt?.toIso8601String(),
};
