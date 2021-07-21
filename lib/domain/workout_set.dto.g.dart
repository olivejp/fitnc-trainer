// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSetDto _$WorkoutSetDtoFromJson(Map<String, dynamic> json) {
  return WorkoutSetDto()
    ..uid = json['uid'] as String?
    ..uidExercice = json['uidExercice'] as String?
    ..consigne = json['consigne'] as String?
    ..order = json['order'] as int
    ..typeExercice = json['typeExercice'] as String?
    ..nameExercice = json['nameExercice'] as String?
    ..imageUrlExercice = json['imageUrlExercice'] as String?
    ..sets = json['sets'] as String?
    ..reps = json['reps'] as String?
    ..weight = json['weight'] as String?
    ..restTime = json['restTime'] as String?
    ..time = json['time'] as String?;
}

Map<String, dynamic> _$WorkoutSetDtoToJson(WorkoutSetDto instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'uidExercice': instance.uidExercice,
      'consigne': instance.consigne,
      'order': instance.order,
      'typeExercice': instance.typeExercice,
      'nameExercice': instance.nameExercice,
      'imageUrlExercice': instance.imageUrlExercice,
      'sets': instance.sets,
      'reps': instance.reps,
      'weight': instance.weight,
      'restTime': instance.restTime,
      'time': instance.time,
    };
