// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercice.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercice _$ExerciceFromJson(Map<String, dynamic> json) {
  return Exercice(
    uid: json['uid'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    createDate: json['createDate'],
  )..imageUrl = json['imageUrl'] as String?;
}

Map<String, dynamic> _$ExerciceToJson(Exercice instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'createDate': instance.createDate,
    };
