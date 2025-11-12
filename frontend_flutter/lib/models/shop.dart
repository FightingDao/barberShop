import 'package:json_annotation/json_annotation.dart';
import '../utils/json_converters.dart';

part 'shop.g.dart';

@JsonSerializable()
class Shop {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? description;
  final String? avatarUrl;
  final String? openingTime;
  final String? closingTime;

  @StringToDoubleConverter()
  final double? latitude;

  @StringToDoubleConverter()
  final double? longitude;

  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.description,
    this.avatarUrl,
    this.openingTime,
    this.closingTime,
    this.latitude,
    this.longitude,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);
  Map<String, dynamic> toJson() => _$ShopToJson(this);
}
