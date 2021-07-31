// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_schedule.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutScheduleDto _$WorkoutScheduleDtoFromJson(Map<String, dynamic> json) {
  return WorkoutScheduleDto()
    ..uid = json['uid'] as String?
    ..uidWorkout = json['uidWorkout'] as String?
    ..nameWorkout = json['nameWorkout'] as String?
    ..dateSchedule = json['dateSchedule'];
}

Map<String, dynamic> _$WorkoutScheduleDtoToJson(WorkoutScheduleDto instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'uidWorkout': instance.uidWorkout,
      'nameWorkout': instance.nameWorkout,
      'dateSchedule': instance.dateSchedule,
    };
