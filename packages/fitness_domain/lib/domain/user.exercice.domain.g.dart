// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.exercice.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserExercice _$UserExerciceFromJson(Map<String, dynamic> json) {
  return UserExercice()
    ..uid = json['uid'] as String?
    ..name = json['name'] as String
    ..createDate = json['createDate']
    ..updateDate = json['updateDate']
    ..creatorUid = json['creatorUid'] as String?
    ..imageUrl = json['imageUrl'] as String?
    ..imageName = json['imageName'] as String?
    ..typeExercice = json['typeExercice'] as String?
    ..videoUrl = json['videoUrl'] as String?
    ..youtubeUrl = json['youtubeUrl'] as String?
    ..description = json['description'] as String
    ..comment = json['comment'] as String?
    ..workingMax = json['workingMax'] as String?;
}

Map<String, dynamic> _$UserExerciceToJson(UserExercice instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'creatorUid': instance.creatorUid,
      'imageUrl': instance.imageUrl,
      'imageName': instance.imageName,
      'typeExercice': instance.typeExercice,
      'videoUrl': instance.videoUrl,
      'youtubeUrl': instance.youtubeUrl,
      'description': instance.description,
      'comment': instance.comment,
      'workingMax': instance.workingMax,
    };
