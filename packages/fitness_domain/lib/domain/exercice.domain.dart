import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'exercice.domain.g.dart';

@JsonSerializable()
class Exercice extends AbstractFitnessStorageDomain implements InterfaceDomainSearchable {
  Exercice() : super();

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

  static Exercice fromJson(Map<String, dynamic> json) {
    return Exercice()
      ..uid = json['uid'] as String?
      ..name = json['name'] as String? ?? ''
      ..createDate = json['createDate']
      ..updateDate = json['updateDate']
      ..imageUrl = json['imageUrl'] as String?
      ..typeExercice = json['typeExercice'] as String?
      ..videoUrl = json['videoUrl'] as String?
      ..youtubeUrl = json['youtubeUrl'] as String?
      ..description = json['description'] as String? ?? '';
  }
}
