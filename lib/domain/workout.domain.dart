import 'package:json_annotation/json_annotation.dart';

part 'workout.domain.g.dart';

@JsonSerializable()
class Workout {
  String uid;
  String name;
  String? imageUrl;
  dynamic createDate;

  Workout({this.uid = '', this.name = '', this.createDate = 0});

  factory Workout.fromJson(Map<String, dynamic> data) =>
      _$WorkoutFromJson(data);

  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}
