import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line.domain.g.dart';

@JsonSerializable()
class Line {
  String? reps;
  String? weight;
  String? repos;
  String? type;
  int? order;

  Line({this.reps = '', this.weight = '', this.order = 0, this.type = ''});

  factory Line.fromJson(Map<String, dynamic> data) => _$LineFromJson(data);

  Map<String, dynamic> toJson() => _$LineToJson(this);
}
