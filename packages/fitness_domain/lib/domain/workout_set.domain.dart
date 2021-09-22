
import 'package:json_annotation/json_annotation.dart';

import 'line.domain.dart';

part 'workout_set.domain.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutSet {
  WorkoutSet({this.uidExercice = '', this.consigne = '', this.order = 0});

  factory WorkoutSet.fromJson(Map<String, dynamic> data) =>
      _$WorkoutSetFromJson(data);

  String? uid;
  String? uidExercice;
  String? uidWorkout;
  String? consigne;
  int order;
  List<Line>? lines;

  Map<String, dynamic> toJson() => _$WorkoutSetToJson(this);
}
