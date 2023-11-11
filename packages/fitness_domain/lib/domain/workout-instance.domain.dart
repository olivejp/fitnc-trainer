import 'package:fitness_domain/enum/type_workout.enum.dart';
import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'workout-instance.domain.g.dart';

@JsonSerializable()
class WorkoutInstance extends AbstractStorageDomain {
  WorkoutInstance();

  factory WorkoutInstance.fromJson(Map<String, dynamic> data) => _$WorkoutInstanceFromJson(data);

  String? timerType;
  String? description;
  dynamic date;
  TypeWorkout? typeWorkout;

  @override
  Map<String, dynamic> toJson() => _$WorkoutInstanceToJson(this);
}
