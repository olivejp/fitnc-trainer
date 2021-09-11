import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'trainers.domain.g.dart';

@JsonSerializable()
class Trainers extends AbstractFitnessStorageDomain {
  Trainers({this.email = '', this.prenom = '', this.telephone = ''}) : super();

  factory Trainers.fromJson(Map<String, dynamic> json) {
    return Trainers(
      email: json['email'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'] as String?,
    )
      ..uid = json['uid'] as String?
      ..name = json['name'] ?? ''
      ..createDate = json['createDate']
      ..updateDate = json['updateDate']
      ..imageUrl = json['imageUrl'] as String?
      ..biopic = json['biopic'] as String?;
  }

  String email;
  String prenom;
  String? telephone;
  String? biopic;

  Map<String, dynamic> toJson() => _$TrainersToJson(this);
}
