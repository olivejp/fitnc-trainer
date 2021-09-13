// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'published_programme.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublishedProgramme _$PublishedProgrammeFromJson(Map<String, dynamic> json) {
  return PublishedProgramme()
    ..uid = json['uid'] as String?
    ..name = json['name'] as String
    ..createDate = json['createDate']
    ..updateDate = json['updateDate']
    ..imageUrl = json['imageUrl'] as String?
    ..numberWeeks = json['numberWeeks'] as String?
    ..available = json['available'] as bool?
    ..description = json['description'] as String?
    ..publishDate = json['publishDate']
    ..creatorUid = json['creatorUid'] as String?
    ..creatorImageUrl = json['creatorImageUrl'] as String?
    ..creatorName = json['creatorName'] as String?
    ..creatorPrenom = json['creatorPrenom'] as String?;
}

Map<String, dynamic> _$PublishedProgrammeToJson(PublishedProgramme instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'imageUrl': instance.imageUrl,
      'numberWeeks': instance.numberWeeks,
      'available': instance.available,
      'description': instance.description,
      'publishDate': instance.publishDate,
      'creatorUid': instance.creatorUid,
      'creatorImageUrl': instance.creatorImageUrl,
      'creatorName': instance.creatorName,
      'creatorPrenom': instance.creatorPrenom,
    };
