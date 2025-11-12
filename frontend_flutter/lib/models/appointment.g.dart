// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  shopId: (json['shopId'] as num).toInt(),
  serviceId: (json['serviceId'] as num).toInt(),
  stylistId: (json['stylistId'] as num?)?.toInt(),
  appointmentDate: json['appointmentDate'] as String,
  appointmentTime: json['appointmentTime'] as String,
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  status: json['status'] as String,
  notes: json['notes'] as String?,
  confirmationCode: json['confirmationCode'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
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
      'userId': instance.userId,
      'shopId': instance.shopId,
      'serviceId': instance.serviceId,
      'stylistId': instance.stylistId,
      'appointmentDate': instance.appointmentDate,
      'appointmentTime': instance.appointmentTime,
      'durationMinutes': instance.durationMinutes,
      'status': instance.status,
      'notes': instance.notes,
      'confirmationCode': instance.confirmationCode,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'shop': instance.shop?.toJson(),
      'service': instance.service?.toJson(),
      'stylist': instance.stylist?.toJson(),
    };
