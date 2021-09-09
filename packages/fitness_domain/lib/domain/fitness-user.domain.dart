import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'fitness-user.domain.g.dart';

@JsonSerializable()
class FitnessUser extends AbstractFitnessStorageDomain implements InterfaceDomainSearchable {
  FitnessUser();

  factory FitnessUser.fromJson(Map<String, dynamic> data) =>_$FitnessUserFromJson(data);

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
  Map<String, dynamic> toJson() => _$FitnessUserToJson(this);

  @override
  List<String> searchFields() {
    return ['nom', 'prenom', 'email'];
  }
}
