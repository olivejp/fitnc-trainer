// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Line _$LineFromJson(Map<String, dynamic> json) {
  return Line()
    ..reps = json['reps'] as String?
    ..weight = json['weight'] as String?
    ..restTime = json['restTime'] as String?
    ..time = json['time'] as String?
    ..order = json['order'] as int?;
}

Map<String, dynamic> _$LineToJson(Line instance) => <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'restTime': instance.restTime,
      'time': instance.time,
      'order': instance.order,
    };
