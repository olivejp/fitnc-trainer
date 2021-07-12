import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line.domain.g.dart';

@JsonSerializable()
class Line {
  late String uid;
  String? reps;
  String? weight;
  String? repos;
  String? type;
  int? order;

  Line({this.reps, this.weight, this.order, this.type});

  factory Line.fromJson(Map<String, dynamic> data) => _$LineFromJson(data);

  Map<String, dynamic> toJson() => _$LineToJson(this);
}
