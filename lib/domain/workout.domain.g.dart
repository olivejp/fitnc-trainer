// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) {
  return Workout(
    uid: json['uid'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    createDate: json['createDate'],
  )
    ..imageUrl = json['imageUrl'] as String?
    ..dateDebut = json['dateDebut']
    ..dateFin = json['dateFin']
    ..timerType = json['timerType'] as String?;
}

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'createDate': instance.createDate,
      'dateDebut': instance.dateDebut,
      'dateFin': instance.dateFin,
      'timerType': instance.timerType,
    };
