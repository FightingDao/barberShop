import 'package:json_annotation/json_annotation.dart';
import 'shop.dart';
import 'service.dart';
import 'stylist.dart';

part 'appointment.g.dart';

@JsonSerializable(explicitToJson: true)
class Appointment {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'shop_id')
  final int shopId;
  @JsonKey(name: 'service_id')
  final int serviceId;
  @JsonKey(name: 'stylist_id')
  final int? stylistId;
  @JsonKey(name: 'appointment_date')
  final String appointmentDate;
  @JsonKey(name: 'appointment_time')
  final String appointmentTime;
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  final String status; // pending, completed, cancelled
  final String? notes;
  @JsonKey(name: 'confirmation_code')
  final String confirmationCode;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // 关联数据
  final Shop? shop;
  final Service? service;
  final Stylist? stylist;

  Appointment({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.serviceId,
    this.stylistId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.durationMinutes,
    required this.status,
    this.notes,
    required this.confirmationCode,
    this.createdAt,
    this.updatedAt,
    this.shop,
    this.service,
    this.stylist,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // 兼容两种格式：camelCase (Prisma) 和 snake_case
    return Appointment(
      id: json['id'] as int,
      userId: (json['user_id'] ?? json['userId']) as int,
      shopId: (json['shop_id'] ?? json['shopId']) as int,
      serviceId: (json['service_id'] ?? json['serviceId']) as int,
      stylistId: json['stylist_id'] ?? json['stylistId'],
      appointmentDate: (json['appointment_date'] ?? json['appointmentDate']) as String,
      appointmentTime: (json['appointment_time'] ?? json['appointmentTime']) as String,
      durationMinutes: (json['duration_minutes'] ?? json['durationMinutes']) as int,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      confirmationCode: (json['confirmation_code'] ?? json['confirmationCode']) as String,
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.parse((json['created_at'] ?? json['createdAt']) as String)
          : null,
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String)
          : null,
      shop: json['shop'] != null ? Shop.fromJson(json['shop'] as Map<String, dynamic>) : null,
      service: json['service'] != null ? Service.fromJson(json['service'] as Map<String, dynamic>) : null,
      stylist: json['stylist'] != null ? Stylist.fromJson(json['stylist'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
