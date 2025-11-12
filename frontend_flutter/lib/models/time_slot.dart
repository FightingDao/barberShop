import 'package:json_annotation/json_annotation.dart';

part 'time_slot.g.dart';

@JsonSerializable()
class TimeSlot {
  final String date;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  TimeSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) => _$TimeSlotFromJson(json);
  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);
}
