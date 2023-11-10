// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.line.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLine _$UserLineFromJson(Map<String, dynamic> json) => UserLine()
  ..reps = json['reps'] as String?
  ..weight = json['weight'] as String?
  ..weightUnit = $enumDecodeNullable(_$WeightUnitEnumMap, json['weightUnit'])
  ..restTime = json['restTime'] as String?
  ..restTimeUnit = $enumDecodeNullable(_$TimeUnitEnumMap, json['restTimeUnit'])
  ..time = json['time'] as String?
  ..timeUnit = $enumDecodeNullable(_$TimeUnitEnumMap, json['timeUnit'])
  ..dist = json['dist'] as String?
  ..distUnit = $enumDecodeNullable(_$DistUnitEnumMap, json['distUnit'])
  ..order = json['order'] as int?
  ..checked = json['checked'] as bool;

Map<String, dynamic> _$UserLineToJson(UserLine instance) => <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'weightUnit': _$WeightUnitEnumMap[instance.weightUnit],
      'restTime': instance.restTime,
      'restTimeUnit': _$TimeUnitEnumMap[instance.restTimeUnit],
      'time': instance.time,
      'timeUnit': _$TimeUnitEnumMap[instance.timeUnit],
      'dist': instance.dist,
      'distUnit': _$DistUnitEnumMap[instance.distUnit],
      'order': instance.order,
      'checked': instance.checked,
    };

const _$WeightUnitEnumMap = {
  WeightUnit.KG: 'KG',
  WeightUnit.LB: 'LB',
};

const _$TimeUnitEnumMap = {
  TimeUnit.HOUR: 'HOUR',
  TimeUnit.MIN: 'MIN',
  TimeUnit.SEC: 'SEC',
};

const _$DistUnitEnumMap = {
  DistUnit.KM: 'KM',
  DistUnit.M: 'M',
  DistUnit.MI: 'MI',
  DistUnit.YD: 'YD',
};
