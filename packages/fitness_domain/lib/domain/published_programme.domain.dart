import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:json_annotation/json_annotation.dart';

part 'published_programme.domain.g.dart';

@JsonSerializable()
class PublishedProgramme extends Programme {
  PublishedProgramme();

  factory PublishedProgramme.fromJson(Map<String, dynamic> data) => _$PublishedProgrammeFromJson(data);

  factory PublishedProgramme.fromProgramme(Programme programme, Trainers trainers) {
    PublishedProgramme publishedProgramme = PublishedProgramme.fromJson(programme.toJson());
    publishedProgramme.creatorUid = trainers.uid;
    publishedProgramme.creatorImageUrl = trainers.imageUrl;
    publishedProgramme.creatorName = trainers.name;
    publishedProgramme.creatorPrenom = trainers.prenom;
    return publishedProgramme;
  }

  String? creatorUid;
  String? creatorImageUrl;
  String? creatorName;
  String? creatorPrenom;

  @override
  Map<String, dynamic> toJson() => _$PublishedProgrammeToJson(this);
}
