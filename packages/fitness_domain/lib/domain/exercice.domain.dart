import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'exercice.domain.g.dart';

@JsonSerializable()
class Exercice extends AbstractStorageDomain implements InterfaceDomainSearchable {
  Exercice() : super();

  String? typeExercice;
  String? videoUrl;
  String? youtubeUrl;
  String description = '';
  String? origin = '';
  List<dynamic>? group = <dynamic>[];

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
      ..group = json['group'] as List<dynamic>?
      ..origin = json['origin'] as String?
      ..description = json['description'] as String? ?? '';
  }
}
