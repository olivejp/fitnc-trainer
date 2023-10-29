// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) => WorkoutSet(
      uidExercice: json['uidExercice'] as String? ?? '',
      consigne: json['consigne'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      uidWorkout: json['uidWorkout'] as String? ?? '',
      nameExercice: json['nameExercice'] as String? ?? '',
    )
      ..uid = json['uid'] as String?
      ..name = json['name'] as String
      ..createDate = json['createDate']
      ..updateDate = json['updateDate']
      ..creatorUid = json['creatorUid'] as String?
      ..typeExercice = json['typeExercice'] as String?
      ..imageUrlExercice = json['imageUrlExercice'] as String?
      ..lines = (json['lines'] as List<dynamic>)
          .map((e) => Line.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$WorkoutSetToJson(WorkoutSet instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'creatorUid': instance.creatorUid,
      'uidWorkout': instance.uidWorkout,
      'uidExercice': instance.uidExercice,
      'nameExercice': instance.nameExercice,
      'consigne': instance.consigne,
      'order': instance.order,
      'typeExercice': instance.typeExercice,
      'imageUrlExercice': instance.imageUrlExercice,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };
