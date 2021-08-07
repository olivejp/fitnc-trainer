// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) {
  return Workout()
    ..uid = json['uid'] as String?
    ..name = json['name'] as String?
    ..imageUrl = json['imageUrl'] as String?
    ..createDate = json['createDate']
    ..description = json['description'] as String?
    ..timerType = json['timerType'] as String?;
}

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'createDate': instance.createDate,
      'description': instance.description,
      'timerType': instance.timerType,
    };
