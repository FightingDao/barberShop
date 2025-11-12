// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stylist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stylist _$StylistFromJson(Map<String, dynamic> json) => Stylist(
  id: (json['id'] as num).toInt(),
  shopId: (json['shopId'] as num).toInt(),
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  title: json['title'] as String?,
  level: json['level'] as String?,
  experienceYears: (json['experienceYears'] as num?)?.toInt(),
  specialties: const CommaSeparatedStringToListConverter().fromJson(
    json['specialties'],
  ),
  status: $enumDecode(_$StylistStatusEnumMap, json['status']),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$StylistToJson(Stylist instance) => <String, dynamic>{
  'id': instance.id,
  'shopId': instance.shopId,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'title': instance.title,
  'level': instance.level,
  'experienceYears': instance.experienceYears,
  'specialties': const CommaSeparatedStringToListConverter().toJson(
    instance.specialties,
  ),
  'status': _$StylistStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$StylistStatusEnumMap = {
  StylistStatus.active: 'active',
  StylistStatus.busy: 'busy',
  StylistStatus.inactive: 'inactive',
};
