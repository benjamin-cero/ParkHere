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
  festivalId: (json['festivalId'] as num?)?.toInt() ?? 0,
  festivalTitle: json['festivalTitle'] as String? ?? '',
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  userFullName: json['userFullName'] as String? ?? '',
  festivalLogo: json['festivalLogo'] as String?,
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'festivalId': instance.festivalId,
  'festivalTitle': instance.festivalTitle,
  'userId': instance.userId,
  'username': instance.username,
  'userFullName': instance.userFullName,
  'festivalLogo': instance.festivalLogo,
};
