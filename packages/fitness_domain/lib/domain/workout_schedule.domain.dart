import 'package:json_annotation/json_annotation.dart';

part 'workout_schedule.domain.g.dart';

@JsonSerializable()
class WorkoutSchedule {
  WorkoutSchedule({this.uid});

  factory WorkoutSchedule.fromJson(Map<String, dynamic> data) =>
      _$WorkoutScheduleFromJson(data);

  String? uid;
  String? uidWorkout;
  dynamic dateSchedule;

  Map<String, dynamic> toJson() => _$WorkoutScheduleToJson(this);
}
