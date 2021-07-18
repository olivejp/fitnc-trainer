// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) {
  return WorkoutSet(
    uidExercice: json['uidExercice'] as String?,
    consigne: json['consigne'] as String?,
    order: json['order'] as int,
  )
    ..uid = json['uid'] as String?
    ..sets = json['sets'] as String?
    ..reps = json['reps'] as int?
    ..weight = json['weight'] as String?
    ..restTime = json['restTime'] as String?
    ..time = json['time'] as String?;
}

Map<String, dynamic> _$WorkoutSetToJson(WorkoutSet instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'uidExercice': instance.uidExercice,
      'consigne': instance.consigne,
      'order': instance.order,
      'sets': instance.sets,
      'reps': instance.reps,
      'weight': instance.weight,
      'restTime': instance.restTime,
      'time': instance.time,
    };
