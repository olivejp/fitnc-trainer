// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programme.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Programme _$ProgrammeFromJson(Map<String, dynamic> json) {
  return Programme()
    ..uid = json['uid'] as String?
    ..name = json['name'] as String
    ..createDate = json['createDate']
    ..updateDate = json['updateDate']
    ..imageUrl = json['imageUrl'] as String?
    ..numberWeeks = json['numberWeeks'] as String?
    ..available = json['available'] as bool?
    ..description = json['description'] as String?
    ..publishDate = json['publishDate'];
}

Map<String, dynamic> _$ProgrammeToJson(Programme instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'imageUrl': instance.imageUrl,
      'numberWeeks': instance.numberWeeks,
      'available': instance.available,
      'description': instance.description,
      'publishDate': instance.publishDate,
    };
