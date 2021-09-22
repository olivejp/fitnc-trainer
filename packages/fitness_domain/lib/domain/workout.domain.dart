import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'workout.domain.g.dart';

@JsonSerializable()
class Workout extends AbstractStorageDomain implements InterfaceDomainSearchable {
  Workout();

  factory Workout.fromJson(Map<String, dynamic> data) => _$WorkoutFromJson(data);

  String? timerType;
  String? description;

  @override
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);

  @override
  List<String> searchFields() {
    return ['name', 'description'];
  }
}
