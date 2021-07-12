// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Line _$LineFromJson(Map<String, dynamic> json) {
  return Line(
    reps: json['reps'] as String?,
    weight: json['weight'] as String?,
    order: json['order'] as int?,
    type: json['type'] as String?,
  )
    ..uid = json['uid'] as String
    ..repos = json['repos'] as String?;
}

Map<String, dynamic> _$LineToJson(Line instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'reps': instance.reps,
      'weight': instance.weight,
      'repos': instance.repos,
      'type': instance.type,
      'order': instance.order,
    };
