// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Line _$LineFromJson(Map<String, dynamic> json) => Line()
  ..reps = json['reps'] as String?
  ..weight = json['weight'] as String?
  ..weightUnit = $enumDecodeNullable(_$WeightUnitEnumMap, json['weightUnit'])
  ..restTime = json['restTime'] as String?
  ..restTimeUnit = $enumDecodeNullable(_$TimeUnitEnumMap, json['restTimeUnit'])
  ..time = json['time'] as String?
  ..timeUnit = $enumDecodeNullable(_$TimeUnitEnumMap, json['timeUnit'])
  ..distance = json['distance'] as String?
  ..distUnit = $enumDecodeNullable(_$DistUnitEnumMap, json['distUnit'])
  ..order = json['order'] as int?;

Map<String, dynamic> _$LineToJson(Line instance) => <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'weightUnit': _$WeightUnitEnumMap[instance.weightUnit],
      'restTime': instance.restTime,
      'restTimeUnit': _$TimeUnitEnumMap[instance.restTimeUnit],
      'time': instance.time,
      'timeUnit': _$TimeUnitEnumMap[instance.timeUnit],
      'distance': instance.distance,
      'distUnit': _$DistUnitEnumMap[instance.distUnit],
      'order': instance.order,
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
