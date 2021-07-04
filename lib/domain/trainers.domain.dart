import 'package:json_annotation/json_annotation.dart';

part 'trainers.domain.g.dart';

@JsonSerializable()
class Trainers {
  String uid;
  String email;

  Trainers({this.uid = '', this.email = ''});

  factory Trainers.fromJson(Map<String, dynamic> data) => _$TrainersFromJson(data);

  Map<String, dynamic> toJson() => _$TrainersToJson(this);
}
