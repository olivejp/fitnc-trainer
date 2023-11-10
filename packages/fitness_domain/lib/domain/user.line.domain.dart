import 'package:fitness_domain/enum/dist_unit.enum.dart';
import 'package:fitness_domain/enum/time_unit.enum.dart';
import 'package:fitness_domain/enum/weight_unit.enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.line.domain.g.dart';

@JsonSerializable()
class UserLine {
  UserLine();

  factory UserLine.fromJson(Map<String, dynamic> data) => _$UserLineFromJson(data);

  String? reps;
  String? weight;
  WeightUnit? weightUnit;
  String? restTime;
  TimeUnit? restTimeUnit;
  String? time;
  TimeUnit? timeUnit;
  String? dist;
  DistUnit? distUnit;
  int? order;
  bool checked = false;

  Map<String, dynamic> toJson() => _$UserLineToJson(this);
}
