// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Program _$ProgramFromJson(Map<String, dynamic> json) {
  return Program(
    uid: json['uid'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    createDate: json['createDate'],
  )..imageUrl = json['imageUrl'] as String?;
}

Map<String, dynamic> _$ProgramToJson(Program instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'createDate': instance.createDate,
    };
