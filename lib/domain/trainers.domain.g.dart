// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainers.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trainers _$TrainersFromJson(Map<String, dynamic> json) {
  return Trainers(
    uid: json['uid'] as String,
    email: json['email'] as String,
    nom: json['nom'] as String,
    prenom: json['prenom'] as String,
    telephone: json['telephone'] as String?,
  );
}

Map<String, dynamic> _$TrainersToJson(Trainers instance) => <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'telephone': instance.telephone,
    };
