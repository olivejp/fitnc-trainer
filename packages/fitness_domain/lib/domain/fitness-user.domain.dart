import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'fitness-user.domain.g.dart';

@JsonSerializable()
class FitnessUser extends AbstractStorageDomain implements InterfaceDomainSearchable {
  FitnessUser();

  static FitnessUser fromJson(Map<String, dynamic> json) {
    return FitnessUser()
      ..uid = json['uid'] as String?
      ..name = (json['name'] as String?) ?? ''
      ..createDate = json['createDate']
      ..updateDate = json['updateDate']
      ..imageUrl = json['imageUrl'] as String?
      ..prenom = json['prenom'] as String?
      ..sexe = json['sexe'] as String?
      ..dateNaissance = json['dateNaissance'] as String?
      ..telephone1 = json['telephone1'] as int?
      ..telephone2 = json['telephone2'] as int?
      ..email = json['email'] as String?
      ..adresse1 = json['adresse1'] as String?
      ..adresse2 = json['adresse2'] as String?
      ..adresse3 = json['adresse3'] as String?;
  }

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
