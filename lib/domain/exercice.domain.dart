import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'exercice.domain.g.dart';

@JsonSerializable()
class Exercice extends AbstractFitnessStorageDomain implements InterfaceDomainSearchable {
  Exercice() : super();

  factory Exercice.fromJson(Map<String, dynamic> data) => _$ExerciceFromJson(data);

  String? typeExercice;
  String? videoUrl;
  String? youtubeUrl;
  String description = '';

  @override
  Map<String, dynamic> toJson() => _$ExerciceToJson(this);

  @override
  List<String> searchFields() {
    return <String>['name', 'description'];
  }
}
