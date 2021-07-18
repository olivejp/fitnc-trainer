import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:json_annotation/json_annotation.dart';

class WorkoutSetDto {
  String? uid;
  String? uidExercice;
  String? consigne;
  int order = 0;

  String? sets; // REPS_WEIGHT, REPS_ONLY , TIME
  int? reps; // REPS_WEIGHT, REPS_ONLY
  String? weight; // REPS_WEIGHT
  String? restTime; // REPS_WEIGHT, REPS_ONLY
  String? time; // TIME

  String? typeExercice;
  String? nameExercice;
  String? imageUrlExercice;

  WorkoutSetDto(WorkoutSet workoutSet) {
    this.uid = workoutSet.uid;
    this.uidExercice = workoutSet.uidExercice;
    this.consigne = workoutSet.consigne;
    this.order = workoutSet.order;
    this.sets = workoutSet.sets;
    this.reps = workoutSet.reps;
    this.weight = workoutSet.weight;
    this.restTime = workoutSet.restTime;
    this.time = workoutSet.time;
  }
}
