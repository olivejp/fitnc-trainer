import 'abstract.domain.dart';

class WorkoutInstance extends AbstractFitnessStorageDomain {
  WorkoutInstance();

  factory WorkoutInstance.fromJson(Map<String, dynamic> json) {
    return WorkoutInstance()
      ..uid = json['uid'] as String?
      ..name = json['name'] as String
      ..createDate = json['createDate']
      ..updateDate = json['updateDate']
      ..imageUrl = json['imageUrl'] as String?
      ..timerType = json['timerType'] as String?
      ..description = json['description'] as String?
      ..date = json['date'] == null ? null : DateTime.fromMillisecondsSinceEpoch(json['date'] as int);
  }

  Map<String, dynamic> _$WorkoutInstanceToJson(WorkoutInstance instance) => <String, dynamic>{
        'uid': instance.uid,
        'name': instance.name,
        'createDate': instance.createDate,
        'updateDate': instance.updateDate,
        'imageUrl': instance.imageUrl,
        'timerType': instance.timerType,
        'description': instance.description,
        'date': instance.date?.millisecondsSinceEpoch,
      };

  String? timerType;
  String? description;
  DateTime? date;

  @override
  Map<String, dynamic> toJson() => _$WorkoutInstanceToJson(this);
}
