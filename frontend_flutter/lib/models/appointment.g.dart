// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  shopId: (json['shop_id'] as num).toInt(),
  serviceId: (json['service_id'] as num).toInt(),
  stylistId: (json['stylist_id'] as num?)?.toInt(),
  appointmentDate: json['appointment_date'] as String,
  appointmentTime: json['appointment_time'] as String,
  durationMinutes: (json['duration_minutes'] as num).toInt(),
  status: json['status'] as String,
  notes: json['notes'] as String?,
  confirmationCode: json['confirmation_code'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  shop: json['shop'] == null
      ? null
      : Shop.fromJson(json['shop'] as Map<String, dynamic>),
  service: json['service'] == null
      ? null
      : Service.fromJson(json['service'] as Map<String, dynamic>),
  stylist: json['stylist'] == null
      ? null
      : Stylist.fromJson(json['stylist'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'shop_id': instance.shopId,
      'service_id': instance.serviceId,
      'stylist_id': instance.stylistId,
      'appointment_date': instance.appointmentDate,
      'appointment_time': instance.appointmentTime,
      'duration_minutes': instance.durationMinutes,
      'status': instance.status,
      'notes': instance.notes,
      'confirmation_code': instance.confirmationCode,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'shop': instance.shop?.toJson(),
      'service': instance.service?.toJson(),
      'stylist': instance.stylist?.toJson(),
    };
