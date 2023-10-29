// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout()
  ..uid = json['uid'] as String?
  ..name = json['name'] as String
  ..createDate = json['createDate']
  ..updateDate = json['updateDate']
  ..creatorUid = json['creatorUid'] as String?
  ..imageUrl = json['imageUrl'] as String?
  ..imageName = json['imageName'] as String?
  ..timerType = json['timerType'] as String?
  ..description = json['description'] as String?
  ..totalTime = json['totalTime'] as int?;

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'creatorUid': instance.creatorUid,
      'imageUrl': instance.imageUrl,
      'imageName': instance.imageName,
      'timerType': instance.timerType,
      'description': instance.description,
      'totalTime': instance.totalTime,
    };
