// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercice.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercice _$ExerciceFromJson(Map<String, dynamic> json) {
  return Exercice()
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
    ..description = json['description'] as String;
}

Map<String, dynamic> _$ExerciceToJson(Exercice instance) => <String, dynamic>{
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
    };
