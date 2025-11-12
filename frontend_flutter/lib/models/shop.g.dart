// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shop _$ShopFromJson(Map<String, dynamic> json) => Shop(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String?,
  description: json['description'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  openingTime: json['openingTime'] as String?,
  closingTime: json['closingTime'] as String?,
  latitude: const StringToDoubleConverter().fromJson(json['latitude']),
  longitude: const StringToDoubleConverter().fromJson(json['longitude']),
  status: json['status'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ShopToJson(Shop instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'phone': instance.phone,
  'description': instance.description,
  'avatarUrl': instance.avatarUrl,
  'openingTime': instance.openingTime,
  'closingTime': instance.closingTime,
  'latitude': const StringToDoubleConverter().toJson(instance.latitude),
  'longitude': const StringToDoubleConverter().toJson(instance.longitude),
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
