import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout.domain.g.dart';

@JsonSerializable()
class Workout extends AbstractFitnessStorageDomain {
  Workout();

  factory Workout.fromJson(Map<String, dynamic> data) => _$WorkoutFromJson(data);

  String? description;
  String? timerType;

  @override
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}
