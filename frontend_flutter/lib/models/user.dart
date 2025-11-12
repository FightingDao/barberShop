import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String phone;
  final String? nickname;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.phone,
    this.nickname,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
