
import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'programme.domain.g.dart';

@JsonSerializable()
class Programme extends AbstractFitnessStorageDomain implements InterfaceDomainSearchable {
  Programme();

  factory Programme.fromJson(Map<String, dynamic> data) => _$ProgrammeFromJson(data);

  String? numberWeeks;
  bool? available;
  String? description;
  dynamic publishDate;

  @override
  Map<String, dynamic> toJson() => _$ProgrammeToJson(this);

  @override
  List<String> searchFields() {
    return ['name', 'description'];
  }
}
