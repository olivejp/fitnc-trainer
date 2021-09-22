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
    ..creatorUid = json['creatorUid'] as String?
    ..imageUrl = json['imageUrl'] as String?
    ..imageName = json['imageName'] as String?
    ..biopic = json['biopic'] as String?;
}

Map<String, dynamic> _$TrainersToJson(Trainers instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'creatorUid': instance.creatorUid,
      'imageUrl': instance.imageUrl,
      'imageName': instance.imageName,
      'email': instance.email,
      'prenom': instance.prenom,
      'telephone': instance.telephone,
      'biopic': instance.biopic,
    };
