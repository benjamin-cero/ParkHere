// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organizer _$OrganizerFromJson(Map<String, dynamic> json) => Organizer(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  contactInfo: json['contactInfo'] as String?,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$OrganizerToJson(Organizer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'contactInfo': instance.contactInfo,
  'isActive': instance.isActive,
};
