import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'abonne.domain.g.dart';

@JsonSerializable()
class Abonne extends AbstractStorageDomain implements InterfaceDomainSearchable {

  Abonne();

  factory Abonne.fromJson(Map<String, dynamic> data) =>_$AbonneFromJson(data);

  String? nom;
  String? prenom;
  String? sexe;
  String? dateNaissance;
  int? telephone1;
  int? telephone2;
  String? email;
  String? adresse1;
  String? adresse2;
  String? adresse3;

  @override
  Map<String, dynamic> toJson() => _$AbonneToJson(this);

  @override
  List<String> searchFields() {
    return ['nom', 'prenom', 'email'];
  }
}
