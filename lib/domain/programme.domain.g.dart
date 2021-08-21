// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programme.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Programme _$ProgrammeFromJson(Map<String, dynamic> json) {
  return Programme()
    ..uid = json['uid'] as String?
    ..name = json['name'] as String?
    ..createDate = json['createDate']
    ..updateDate = json['updateDate']
    ..publishDate = json['publishDate']
    ..imageUrl = json['imageUrl'] as String?
    ..description = json['description'] as String?
    ..numberWeeks = json['numberWeeks'] as String?
    ..available = json['available'] as bool?;
}

Map<String, dynamic> _$ProgrammeToJson(Programme instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'publishDate': instance.publishDate,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'numberWeeks': instance.numberWeeks,
      'available': instance.available,
    };
