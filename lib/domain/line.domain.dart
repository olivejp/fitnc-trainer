import 'package:json_annotation/json_annotation.dart';

part 'line.domain.g.dart';

@JsonSerializable()
class Line {

  Line();

  factory Line.fromJson(Map<String, dynamic> data) => _$LineFromJson(data);

  String? reps;
  String? weight;
  String? restTime;
  String? time;
  int? order;

  Map<String, dynamic> toJson() => _$LineToJson(this);
}
