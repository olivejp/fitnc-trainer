import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:json_annotation/json_annotation.dart';

part 'published_programme.domain.g.dart';

@JsonSerializable()
class PublishedProgramme extends Programme {
  PublishedProgramme();

  factory PublishedProgramme.fromJson(Map<String, dynamic> data) => _$PublishedProgrammeFromJson(data);

  String? creatorUid;
  String? creatorImageUrl;

  @override
  Map<String, dynamic> toJson() => _$PublishedProgrammeToJson(this);

  factory PublishedProgramme.fromProgramme(Programme programme, Trainers trainers) {
    PublishedProgramme publishedProgramme = PublishedProgramme.fromJson(programme.toJson());
    publishedProgramme.creatorUid = trainers.uid;
    publishedProgramme.creatorImageUrl = trainers.imageUrl;
    return publishedProgramme;
  }
}
