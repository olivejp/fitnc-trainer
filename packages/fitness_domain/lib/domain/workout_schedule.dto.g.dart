// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_schedule.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutScheduleDto _$WorkoutScheduleDtoFromJson(Map<String, dynamic> json) =>
    WorkoutScheduleDto()
      ..uid = json['uid'] as String?
      ..uidWorkout = json['uidWorkout'] as String?
      ..dateSchedule = json['dateSchedule']
      ..nameWorkout = json['nameWorkout'] as String?
      ..imageUrlWorkout = json['imageUrlWorkout'] as String?;

Map<String, dynamic> _$WorkoutScheduleDtoToJson(WorkoutScheduleDto instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'uidWorkout': instance.uidWorkout,
      'dateSchedule': instance.dateSchedule,
      'nameWorkout': instance.nameWorkout,
      'imageUrlWorkout': instance.imageUrlWorkout,
    };
