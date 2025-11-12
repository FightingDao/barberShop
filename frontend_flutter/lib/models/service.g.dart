// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
  id: (json['id'] as num).toInt(),
  shopId: (json['shopId'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  price: const StringToDoubleRequiredConverter().fromJson(json['price']),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  iconUrl: json['iconUrl'] as String?,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
  'id': instance.id,
  'shopId': instance.shopId,
  'name': instance.name,
  'description': instance.description,
  'price': const StringToDoubleRequiredConverter().toJson(instance.price),
  'durationMinutes': instance.durationMinutes,
  'iconUrl': instance.iconUrl,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
};
