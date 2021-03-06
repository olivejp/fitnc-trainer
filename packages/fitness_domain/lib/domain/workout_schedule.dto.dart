import 'package:json_annotation/json_annotation.dart';

import 'workout_schedule.domain.dart';

part 'workout_schedule.dto.g.dart';

@JsonSerializable()
class WorkoutScheduleDto {
  WorkoutScheduleDto();

  WorkoutScheduleDto.empty();

  WorkoutScheduleDto.fromSchedule(WorkoutSchedule workoutSchedule) {
    uid = workoutSchedule.uid;
    uidWorkout = workoutSchedule.uidWorkout;
    dateSchedule = workoutSchedule.dateSchedule;
  }

  String? uid;
  String? uidWorkout;
  dynamic dateSchedule;

  String? nameWorkout;
  String? imageUrlWorkout;

  Map<String, dynamic> toJson() => _$WorkoutScheduleDtoToJson(this);
}
