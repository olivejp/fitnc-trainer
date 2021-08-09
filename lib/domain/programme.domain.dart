import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:json_annotation/json_annotation.dart';

part 'programme.domain.g.dart';

@JsonSerializable()
class Programme extends AbstractFitnessStorageDomain {
  Programme();

  factory Programme.fromJson(Map<String, dynamic> data) => _$ProgrammeFromJson(data);

  String? description;
  String? numberWeeks;
  bool? available;

  @override
  Map<String, dynamic> toJson() => _$ProgrammeToJson(this);
}
