import 'package:json_annotation/json_annotation.dart';

part 'abonne.domain.g.dart';

@JsonSerializable()
class Abonne {
  String? uid;
  String? nom;
  String? prenom;
  String? sexe;
  dynamic dateNaissance;
  int? telephone1;
  int? telephone2;
  String? email;
  String? adresse1;
  String? adresse2;
  String? adresse3;
  String? imageUrl;
  dynamic createDate;

  Abonne();

  factory Abonne.fromJson(Map<String, dynamic> data) =>
      _$AbonneFromJson(data);

  Map<String, dynamic> toJson() => _$AbonneToJson(this);
}
