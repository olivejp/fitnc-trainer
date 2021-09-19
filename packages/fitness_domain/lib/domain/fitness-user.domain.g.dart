// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitness-user.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FitnessUser _$FitnessUserFromJson(Map<String, dynamic> json) {
  return FitnessUser()
    ..uid = json['uid'] as String?
    ..name = json['name'] as String
    ..createDate = json['createDate']
    ..updateDate = json['updateDate']
    ..imageUrl = json['imageUrl'] as String?
    ..prenom = json['prenom'] as String?
    ..sexe = json['sexe'] as String?
    ..dateNaissance = json['dateNaissance'] as String?
    ..telephone1 = json['telephone1'] as int?
    ..telephone2 = json['telephone2'] as int?
    ..email = json['email'] as String?
    ..adresse1 = json['adresse1'] as String?
    ..adresse2 = json['adresse2'] as String?
    ..adresse3 = json['adresse3'] as String?;
}

Map<String, dynamic> _$FitnessUserToJson(FitnessUser instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'imageUrl': instance.imageUrl,
      'prenom': instance.prenom,
      'sexe': instance.sexe,
      'dateNaissance': instance.dateNaissance,
      'telephone1': instance.telephone1,
      'telephone2': instance.telephone2,
      'email': instance.email,
      'adresse1': instance.adresse1,
      'adresse2': instance.adresse2,
      'adresse3': instance.adresse3,
    };
