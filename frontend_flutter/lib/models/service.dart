import 'package:json_annotation/json_annotation.dart';
import '../utils/json_converters.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  final int id;
  final int shopId;
  final String name;
  final String? description;

  @StringToDoubleRequiredConverter()
  final double price;

  final int durationMinutes;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;

  Service({
    required this.id,
    required this.shopId,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.iconUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
