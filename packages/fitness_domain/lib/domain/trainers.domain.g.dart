// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainers.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trainers _$TrainersFromJson(Map<String, dynamic> json) {
  return Trainers(
    email: json['email'] as String,
    prenom: json['prenom'] as String,
    telephone: json['telephone'] as String?,
  )
    ..uid = json['uid'] as String?
    ..name = json['name'] as String
    ..createDate = json['createDate']
    ..updateDate = json['updateDate']
    ..imageUrl = json['imageUrl'] as String?
    ..biopic = json['biopic'] as String?;
}

Map<String, dynamic> _$TrainersToJson(Trainers instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'imageUrl': instance.imageUrl,
      'email': instance.email,
      'prenom': instance.prenom,
      'telephone': instance.telephone,
      'biopic': instance.biopic,
    };
