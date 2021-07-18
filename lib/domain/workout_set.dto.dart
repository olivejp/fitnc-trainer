import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:json_annotation/json_annotation.dart';

class WorkoutSetDto {
  String? uid;
  String? uidExercice;
  String? nameExercice;
  String? imageUrlExercice;
  String? consigne;
  int order = 0;
  List<Line> lines = [];

  WorkoutSetDto(WorkoutSet workoutSet) {
    this.uid = workoutSet.uid;
    this.uidExercice = workoutSet.uidExercice;
    this.consigne = workoutSet.consigne;
    this.order = workoutSet.order;
    this.lines = workoutSet.lines;
  }
}
