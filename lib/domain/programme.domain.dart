import 'package:json_annotation/json_annotation.dart';

part 'programme.domain.g.dart';

@JsonSerializable()
class Programme {
  Programme({this.uid, this.name = '', this.description = '', this.createDate = 0});

  factory Programme.fromJson(Map<String, dynamic> data) => _$ProgrammeFromJson(data);

  String? uid;
  String name;
  String? description;
  String? imageUrl;
  dynamic createDate;
  String? numberWeeks;

  Map<String, dynamic> toJson() => _$ProgrammeToJson(this);
}
