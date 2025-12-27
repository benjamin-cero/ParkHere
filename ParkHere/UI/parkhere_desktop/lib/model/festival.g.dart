// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'festival.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Festival _$FestivalFromJson(Map<String, dynamic> json) => Festival(
  id: (json['id'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  logo: json['logo'] as String?,
  countryFlag: json['countryFlag'] as String?,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
  location: json['location'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  cityId: (json['cityId'] as num?)?.toInt() ?? 0,
  cityName: json['cityName'] as String? ?? '',
  countryName: json['countryName'] as String? ?? '',
  subcategoryId: (json['subcategoryId'] as num?)?.toInt() ?? 0,
  subcategoryName: json['subcategoryName'] as String? ?? '',
  categoryName: json['categoryName'] as String? ?? '',
  organizerId: (json['organizerId'] as num?)?.toInt() ?? 0,
  organizerName: json['organizerName'] as String? ?? '',
  assets:
      (json['assets'] as List<dynamic>?)
          ?.map((e) => Asset.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$FestivalToJson(Festival instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'logo': instance.logo,
  'countryFlag': instance.countryFlag,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'basePrice': instance.basePrice,
  'location': instance.location,
  'isActive': instance.isActive,
  'cityId': instance.cityId,
  'cityName': instance.cityName,
  'countryName': instance.countryName,
  'subcategoryId': instance.subcategoryId,
  'subcategoryName': instance.subcategoryName,
  'categoryName': instance.categoryName,
  'organizerId': instance.organizerId,
  'organizerName': instance.organizerName,
  'assets': instance.assets,
};
