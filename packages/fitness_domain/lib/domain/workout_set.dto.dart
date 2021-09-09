import 'package:json_annotation/json_annotation.dart';

import 'line.domain.dart';
import 'workout_set.domain.dart';

part 'workout_set.dto.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutSetDto {
  WorkoutSetDto();

  WorkoutSetDto.fromSet(WorkoutSet workoutSet) {
    uid = workoutSet.uid;
    uidExercice = workoutSet.uidExercice;
    consigne = workoutSet.consigne;
    order = workoutSet.order;
    lines = ((workoutSet.lines != null) ? workoutSet.lines : <Line>[Line()])!;
  }

  WorkoutSetDto.empty();

  String? uid;
  String? uidExercice;
  String? consigne;
  int order = 0;

  String? typeExercice;
  String? nameExercice;
  String? imageUrlExercice;
  List<Line> lines = [];

  Map<String, dynamic> toJson() => _$WorkoutSetDtoToJson(this);
}
