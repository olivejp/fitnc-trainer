// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.line.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLine _$UserLineFromJson(Map<String, dynamic> json) {
  return UserLine()
    ..reps = json['reps'] as String?
    ..weight = json['weight'] as String?
    ..restTime = json['restTime'] as String?
    ..time = json['time'] as String?
    ..order = json['order'] as int?
    ..checked = json['checked'] as bool;
}

Map<String, dynamic> _$UserLineToJson(UserLine instance) => <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'restTime': instance.restTime,
      'time': instance.time,
      'order': instance.order,
      'checked': instance.checked,
    };
