import 'package:fitness_domain/enum/dist_unit.enum.dart';
import 'package:fitness_domain/enum/time_unit.enum.dart';
import 'package:fitness_domain/enum/weight_unit.enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line.domain.g.dart';

@JsonSerializable()
class Line {
  Line();

  factory Line.fromJson(Map<String, dynamic> data) => _$LineFromJson(data);

  String? reps;
  String? weight;
  WeightUnit? weightUnit;
  String? restTime;
  TimeUnit? restTimeUnit;
  String? time;
  TimeUnit? timeUnit;
  String? distance;
  DistUnit? distUnit;
  int? order;

  Map<String, dynamic> toJson() => _$LineToJson(this);
}
