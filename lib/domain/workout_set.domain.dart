import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_set.domain.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutSet {

  WorkoutSet({this.uidExercice = '', this.consigne = '', this.order = 0});

  factory WorkoutSet.fromJson(Map<String, dynamic> data) => _$WorkoutSetFromJson(data);

  String? uid;
  String? uidExercice;
  String? consigne;
  int order;

  String? sets; // REPS_WEIGHT, REPS_ONLY , TIME
  String? reps; // REPS_WEIGHT, REPS_ONLY
  String? weight; // REPS_WEIGHT
  String? restTime; // REPS_WEIGHT, REPS_ONLY
  String? time; // TIME

  Map<String, dynamic> toJson() => _$WorkoutSetToJson(this);
}
