import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class AbstractFitnessDomain {
  AbstractFitnessDomain();

  String? uid;
  String? name;
  dynamic createDate;
  dynamic updateDate;

  Map<String, dynamic> toJson();
}

abstract class AbstractFitnessStorageDomain extends AbstractFitnessDomain {
  AbstractFitnessStorageDomain();

  String? imageUrl;

  @JsonKey(ignore: true)
  StorageFile? storageFile;
}
