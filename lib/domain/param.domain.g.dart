// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'param.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Param _$ParamFromJson(Map<String, dynamic> json) {
  return Param()
    ..uid = json['uid'] as String?
    ..nom = json['nom'] as String?
    ..libelle = json['libelle'] as String?
    ..valeur = json['valeur'] as String?;
}

Map<String, dynamic> _$ParamToJson(Param instance) => <String, dynamic>{
      'uid': instance.uid,
      'nom': instance.nom,
      'libelle': instance.libelle,
      'valeur': instance.valeur,
    };
