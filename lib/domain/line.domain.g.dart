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
    ..repos = json['repos'] as String?;
}

Map<String, dynamic> _$LineToJson(Line instance) => <String, dynamic>{

      'reps': instance.reps,
      'weight': instance.weight,
      'repos': instance.repos,
      'type': instance.type,
      'order': instance.order,
    };
