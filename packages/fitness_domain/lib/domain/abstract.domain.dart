import 'package:fitness_domain/domain/storage-file.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class InterfaceToJson {
  Map<String, dynamic> toJson();
}

abstract class AbstractDomain implements InterfaceToJson {
  AbstractDomain();

  String? uid;
  String name = '';
  dynamic createDate;
  dynamic updateDate;
  String? creatorUid;
}

abstract class AbstractStorageDomain extends AbstractDomain {
  AbstractStorageDomain();

  String? imageUrl;
  String? imageName;

  @JsonKey(ignore: true)
  StorageFile? storageFile;
}

abstract class InterfaceDomainSearchable extends InterfaceToJson {
  List<String> searchFields();
}
