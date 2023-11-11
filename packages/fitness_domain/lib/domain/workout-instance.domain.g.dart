// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout-instance.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutInstance _$WorkoutInstanceFromJson(Map<String, dynamic> json) =>
    WorkoutInstance()
      ..uid = json['uid'] as String?
      ..name = json['name'] as String
      ..createDate = json['createDate']
      ..updateDate = json['updateDate']
      ..creatorUid = json['creatorUid'] as String?
      ..imageUrl = json['imageUrl'] as String?
      ..imageName = json['imageName'] as String?
      ..timerType = json['timerType'] as String?
      ..description = json['description'] as String?
      ..date = json['date']
      ..typeWorkout =
          $enumDecodeNullable(_$TypeWorkoutEnumMap, json['typeWorkout']);

Map<String, dynamic> _$WorkoutInstanceToJson(WorkoutInstance instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'creatorUid': instance.creatorUid,
      'imageUrl': instance.imageUrl,
      'imageName': instance.imageName,
      'timerType': instance.timerType,
      'description': instance.description,
      'date': instance.date,
      'typeWorkout': _$TypeWorkoutEnumMap[instance.typeWorkout],
    };

const _$TypeWorkoutEnumMap = {
  TypeWorkout.AMRAP: 'AMRAP',
  TypeWorkout.CIRCUIT: 'CIRCUIT',
  TypeWorkout.EMOM: 'EMOM',
  TypeWorkout.SIMPLE: 'SIMPLE',
  TypeWorkout.TABATA: 'TABATA',
};
