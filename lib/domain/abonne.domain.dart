import 'package:json_annotation/json_annotation.dart';

part 'abonne.domain.g.dart';

@JsonSerializable()
class Abonne {
  String uid;
  String name;
  dynamic createDate;

  Abonne({this.uid = '', this.name = '', this.createDate = 0});

  factory Abonne.fromJson(Map<String, dynamic> data) =>
      _$AbonneFromJson(data);

  Map<String, dynamic> toJson() => _$AbonneToJson(this);
}
