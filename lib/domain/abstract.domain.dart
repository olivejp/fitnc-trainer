import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class AbstractFirebaseDomain {
  AbstractFirebaseDomain();

  String? uid;
  String? name;
  dynamic createDate;
  dynamic updateDate;

  Map<String, dynamic> toJson();
}

abstract class AbstractFitnessStorageDomain extends AbstractFirebaseDomain {
  AbstractFitnessStorageDomain();

  String? imageUrl;

  @JsonKey(ignore: true)
  StorageFile? storageFile;
}
