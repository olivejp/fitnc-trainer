// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.set.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSet _$UserSetFromJson(Map<String, dynamic> json) {
  return UserSet(
    uidExercice: json['uidExercice'] as String,
    order: json['order'] as int,
    uidWorkout: json['uidWorkout'] as String,
    nameExercice: json['nameExercice'] as String?,
    imageUrlExercice: json['imageUrlExercice'] as String?,
    typeExercice: json['typeExercice'] as String?,
  )
    ..uid = json['uid'] as String?
    ..name = json['name'] as String
    ..createDate = json['createDate']
    ..updateDate = json['updateDate']
    ..creatorUid = json['creatorUid'] as String?
    ..comment = json['comment'] as String?
    ..date =
        json['date'] == null ? null : DateTime.parse(json['date'] as String)
    ..lines = (json['lines'] as List<dynamic>)
        .map((e) => UserLine.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$UserSetToJson(UserSet instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'createDate': instance.createDate,
      'updateDate': instance.updateDate,
      'creatorUid': instance.creatorUid,
      'uidWorkout': instance.uidWorkout,
      'uidExercice': instance.uidExercice,
      'comment': instance.comment,
      'order': instance.order,
      'nameExercice': instance.nameExercice,
      'typeExercice': instance.typeExercice,
      'imageUrlExercice': instance.imageUrlExercice,
      'date': instance.date?.toIso8601String(),
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };
