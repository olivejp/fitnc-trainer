import 'package:json_annotation/json_annotation.dart';

part 'exercice.domain.g.dart';

@JsonSerializable()
class Exercice {
  String? uid;
  String name;
  String? description;
  String? imageUrl;
  dynamic createDate;

  Exercice({this.uid, this.name = '', this.description = '', this.createDate = 0});

  factory Exercice.fromJson(Map<String, dynamic> data) =>
      _$ExerciceFromJson(data);

  Map<String, dynamic> toJson() => _$ExerciceToJson(this);
}
