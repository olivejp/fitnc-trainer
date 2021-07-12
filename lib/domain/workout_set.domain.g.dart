// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) {
  return WorkoutSet()
    ..uid = json['uid'] as String?
    ..uidExercice = json['uidExercice'] as String?
    ..consigne = json['consigne'] as String?;
}

Map<String, dynamic> _$WorkoutSetToJson(WorkoutSet instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'uidExercice': instance.uidExercice,
      'consigne': instance.consigne,
    };
