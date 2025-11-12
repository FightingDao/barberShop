// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) => TimeSlot(
  date: json['date'] as String,
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  isAvailable: json['isAvailable'] as bool,
);

Map<String, dynamic> _$TimeSlotToJson(TimeSlot instance) => <String, dynamic>{
  'date': instance.date,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'isAvailable': instance.isAvailable,
};
