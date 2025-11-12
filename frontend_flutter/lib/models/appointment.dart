import 'package:json_annotation/json_annotation.dart';
import 'shop.dart';
import 'service.dart';
import 'stylist.dart';

part 'appointment.g.dart';

@JsonSerializable(explicitToJson: true)
class Appointment {
  final int id;
  final int userId;
  final int shopId;
  final int serviceId;
  final int? stylistId;
  final String appointmentDate;
  final String appointmentTime;
  final int durationMinutes;
  final String status; // pending, completed, cancelled
  final String? notes;
  final String confirmationCode;
  final DateTime? createdAt;
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

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
