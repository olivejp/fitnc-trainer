import 'package:json_annotation/json_annotation.dart';

part 'user.line.domain.g.dart';

@JsonSerializable()
class UserLine {
  UserLine();

  factory UserLine.fromJson(Map<String, dynamic> data) => _$UserLineFromJson(data);

  String? reps;
  String? weight;
  String? restTime;
  String? time;
  int? order;
  bool checked = false;

  Map<String, dynamic> toJson() => _$UserLineToJson(this);
}
