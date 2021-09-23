import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:json_annotation/json_annotation.dart';

import 'line.domain.dart';

part 'workout_set.domain.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutSet extends AbstractSubDomain {
  WorkoutSet({this.uidExercice = '', this.consigne = '', this.order = 0, this.uidWorkout = '', this.nameExercice = ''});

  factory WorkoutSet.fromJson(Map<String, dynamic> data) => _$WorkoutSetFromJson(data);

  String uidWorkout;
  String uidExercice;
  String nameExercice;
  String? consigne;
  int order = 0;

  String? typeExercice;
  String? imageUrlExercice;
  List<Line> lines = <Line>[];

  Map<String, dynamic> toJson() => _$WorkoutSetToJson(this);

  @override
  String getParentUid() {
    return uidWorkout;
  }
}
