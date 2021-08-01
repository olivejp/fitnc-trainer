// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programme.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Programme _$ProgrammeFromJson(Map<String, dynamic> json) {
  return Programme(
    uid: json['uid'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    createDate: json['createDate'],
  )
    ..imageUrl = json['imageUrl'] as String?
    ..numberWeeks = json['numberWeeks'] as String?;
}

Map<String, dynamic> _$ProgrammeToJson(Programme instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'createDate': instance.createDate,
      'numberWeeks': instance.numberWeeks,
    };
