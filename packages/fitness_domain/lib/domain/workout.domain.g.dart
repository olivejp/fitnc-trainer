// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) {
  return Workout()
    ..uid = json['uid'] as String?
    ..name = json['name'] as String
    ..createDate = json['createDate']
    ..updateDate = json['updateDate']
    ..imageUrl = json['imageUrl'] as String?
    ..timerType = json['timerType'] as String?
    ..description = json['description'] as String?;
}

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'imageUrl': instance.imageUrl,
      'timerType': instance.timerType,
      'description': instance.description,
    };
