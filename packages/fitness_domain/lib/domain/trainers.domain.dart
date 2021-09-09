import 'package:json_annotation/json_annotation.dart';

part 'trainers.domain.g.dart';

@JsonSerializable()
class Trainers {
  Trainers({this.uid = '', this.email = '', this.nom = '', this.prenom = '', this.telephone = ''});

  factory Trainers.fromJson(Map<String, dynamic> data) => _$TrainersFromJson(data);

  String uid;
  String email;
  String nom;
  String prenom;
  String? telephone;

  Map<String, dynamic> toJson() => _$TrainersToJson(this);
}
