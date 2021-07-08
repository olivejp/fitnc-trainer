import 'package:json_annotation/json_annotation.dart';

part 'param.domain.g.dart';

@JsonSerializable()
class Param {
  String? uid;
  String? nom;
  String? libelle;
  String? valeur;

  Param();

  factory Param.fromJson(Map<String, dynamic> data) =>
      _$ParamFromJson(data);

  Map<String, dynamic> toJson() => _$ParamToJson(this);
}
