// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programme.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Programme _$ProgrammeFromJson(Map<String, dynamic> json) {
  return Programme()
    ..uid = json['uid'] as String?
    ..name = json['name'] as String?
    ..imageUrl = json['imageUrl'] as String?
    ..createDate = json['createDate']
    ..description = json['description'] as String?
    ..numberWeeks = json['numberWeeks'] as String?;
}

Map<String, dynamic> _$ProgrammeToJson(Programme instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'createDate': instance.createDate,
      'description': instance.description,
      'numberWeeks': instance.numberWeeks,
    };
