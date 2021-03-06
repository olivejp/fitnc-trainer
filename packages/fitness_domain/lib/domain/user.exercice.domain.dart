import 'package:json_annotation/json_annotation.dart';

import 'exercice.domain.dart';

part 'user.exercice.domain.g.dart';

@JsonSerializable()
class UserExercice extends Exercice {
  UserExercice() : super();

  factory UserExercice.fromJson(Map<String, dynamic> data) => _$UserExerciceFromJson(data);

  String? comment;
  String? oneRepMax; // How much you can lift in one rep.

  @override
  Map<String, dynamic> toJson() => _$UserExerciceToJson(this);
}
