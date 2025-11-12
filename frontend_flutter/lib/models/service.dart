import 'package:json_annotation/json_annotation.dart';
import '../utils/json_converters.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  final int id;
  final int? shopId;  // 改为可选
  final String name;
  final String? description;

  @StringToDoubleRequiredConverter()
  final double price;

  final int durationMinutes;
  final String? iconUrl;

  @JsonKey(defaultValue: 0)
  final int? sortOrder;  // 改为可选

  @JsonKey(defaultValue: true)
  final bool? isActive;  // 改为可选

  final DateTime? createdAt;

  Service({
    required this.id,
    this.shopId,  // 改为可选
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.iconUrl,
    this.sortOrder,  // 改为可选
    this.isActive,  // 改为可选
    this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
