import 'package:json_annotation/json_annotation.dart';

part 'programme.domain.g.dart';

@JsonSerializable()
class Programme {
  String? uid;
  String name;
  String? description;
  String? imageUrl;
  dynamic createDate;

  Programme({this.uid, this.name = '', this.description = '', this.createDate = 0});

  factory Programme.fromJson(Map<String, dynamic> data) =>
      _$ProgrammeFromJson(data);

  Map<String, dynamic> toJson() => _$ProgrammeToJson(this);
}
