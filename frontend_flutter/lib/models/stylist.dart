import 'package:json_annotation/json_annotation.dart';
import '../utils/json_converters.dart';

part 'stylist.g.dart';

/// 理发师状态枚举
enum StylistStatus {
  @JsonValue('active')
  active,
  @JsonValue('busy')
  busy,
  @JsonValue('inactive')
  inactive,
}

@JsonSerializable()
class Stylist {
  final int id;
  final int? shopId;  // 改为可选，因为API响应中不包含此字段
  final String name;
  final String? avatarUrl;
  final String? title;
  final String? level; // 等级：初级/中级/高级/专家
  final int? experienceYears;

  @CommaSeparatedStringToListConverter()
  final List<String>? specialties;

  final StylistStatus status;
  final DateTime? createdAt;

  Stylist({
    required this.id,
    this.shopId,  // 改为可选
    required this.name,
    this.avatarUrl,
    this.title,
    this.level,
    this.experienceYears,
    this.specialties,
    required this.status,
    this.createdAt,
  });

  // 便捷getter
  int? get experience => experienceYears;
  String? get specialty => specialties?.isNotEmpty == true ? specialties!.join('、') : null;

  factory Stylist.fromJson(Map<String, dynamic> json) => _$StylistFromJson(json);
  Map<String, dynamic> toJson() => _$StylistToJson(this);
}
