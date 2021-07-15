import 'package:json_annotation/json_annotation.dart';

part 'program.domain.g.dart';

@JsonSerializable()
class Program {
  String? uid;
  String name;
  String? description;
  String? imageUrl;
  dynamic createDate;

  Program({this.uid, this.name = '', this.description = '', this.createDate = 0});

  factory Program.fromJson(Map<String, dynamic> data) =>
      _$ProgramFromJson(data);

  Map<String, dynamic> toJson() => _$ProgramToJson(this);
}
