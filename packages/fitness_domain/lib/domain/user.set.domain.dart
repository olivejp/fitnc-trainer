import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.set.domain.g.dart';

@JsonSerializable(explicitToJson: true)
class UserSet extends AbstractSubDomain {
  UserSet({this.uidExercice = '', this.order = 0, this.uidWorkout = '', this.nameExercice = '', this.imageUrlExercice, this.typeExercice = '',});

  factory UserSet.fromJson(Map<String, dynamic> data) => _$UserSetFromJson(data);

  String uidWorkout;
  String uidExercice;
  String? comment;
  int order = 0;

  String? nameExercice = '';
  String? typeExercice = '';
  String? imageUrlExercice;

  List<UserLine> lines = <UserLine>[];

  Map<String, dynamic> toJson() => _$UserSetToJson(this);

  @override
  String getParentUid() {
    return uidWorkout;
  }
}
