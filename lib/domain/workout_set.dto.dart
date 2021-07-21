import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_set.dto.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutSetDto {

  WorkoutSetDto();

  WorkoutSetDto.fromSet(WorkoutSet workoutSet) {
    uid = workoutSet.uid;
    uidExercice = workoutSet.uidExercice;
    consigne = workoutSet.consigne;
    order = workoutSet.order;
    sets = workoutSet.sets;
    reps = workoutSet.reps;
    weight = workoutSet.weight;
    restTime = workoutSet.restTime;
    time = workoutSet.time;
  }

  WorkoutSetDto.empty();

  String? uid;
  String? uidExercice;
  String? consigne;
  int order = 0;

  String? typeExercice;
  String? nameExercice;
  String? imageUrlExercice;

  String? sets; // REPS_WEIGHT, REPS_ONLY , TIME
  String? reps; // REPS_WEIGHT, REPS_ONLY
  String? weight; // REPS_WEIGHT
  String? restTime; // REPS_WEIGHT, REPS_ONLY
  String? time; // TIME

  Map<String, dynamic> toJson() => _$WorkoutSetDtoToJson(this);
}
