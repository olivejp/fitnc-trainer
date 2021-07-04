// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abonne.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Abonne _$AbonneFromJson(Map<String, dynamic> json) {
  return Abonne(
    uid: json['uid'] as String,
    name: json['name'] as String,
    createDate: json['createDate'],
  );
}

Map<String, dynamic> _$AbonneToJson(Abonne instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
    };
