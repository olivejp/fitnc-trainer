// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_schedule.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSchedule _$WorkoutScheduleFromJson(Map<String, dynamic> json) {
  return WorkoutSchedule(
    uid: json['uid'] as String?,
  )
    ..uidWorkout = json['uidWorkout'] as String?
    ..dateSchedule = json['dateSchedule'];
}

Map<String, dynamic> _$WorkoutScheduleToJson(WorkoutSchedule instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'uidWorkout': instance.uidWorkout,
      'dateSchedule': instance.dateSchedule,
    };
