// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      reservationId: (json['reservationId'] as num?)?.toInt() ?? 0,
      parkingReservation: json['parkingReservation'] == null
          ? null
          : ParkingReservation.fromJson(
              json['parkingReservation'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
      'reservationId': instance.reservationId,
      'parkingReservation': instance.parkingReservation,
      'user': instance.user,
    };
