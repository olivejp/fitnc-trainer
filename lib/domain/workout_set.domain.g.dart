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
    ..lines = (json['lines'] as List<dynamic>)
        .map((e) => Line.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$WorkoutSetToJson(WorkoutSet instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'uidExercice': instance.uidExercice,
      'consigne': instance.consigne,
      'order': instance.order,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };
