// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abonne.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Abonne _$AbonneFromJson(Map<String, dynamic> json) {
  return Abonne()
    ..uid = json['uid'] as String?
    ..name = json['name'] as String
    ..createDate = json['createDate']
    ..updateDate = json['updateDate']
    ..creatorUid = json['creatorUid'] as String?
    ..imageUrl = json['imageUrl'] as String?
    ..imageName = json['imageName'] as String?
    ..nom = json['nom'] as String?
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

Map<String, dynamic> _$AbonneToJson(Abonne instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'creatorUid': instance.creatorUid,
      'imageUrl': instance.imageUrl,
      'imageName': instance.imageName,
      'nom': instance.nom,
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
