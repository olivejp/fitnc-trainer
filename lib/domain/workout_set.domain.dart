import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_set.domain.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutSet {
  String? uid;
  String? uidExercice;
  String? consigne;
  List<Line> lines = [];

  WorkoutSet({this.uidExercice = '', this.consigne = ''});

  factory WorkoutSet.fromJson(Map<String, dynamic> data) => _$WorkoutSetFromJson(data);

  Map<String, dynamic> toJson() => _$WorkoutSetToJson(this);
}
