import 'package:fitness_domain/domain/storage-file.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class AbstractDomain extends InterfaceToJson {
  AbstractDomain();

  String? uid;
  String name = '';
  dynamic createDate;
  dynamic updateDate;
}

abstract class AbstractFitnessStorageDomain extends AbstractDomain {

  AbstractFitnessStorageDomain();

  String? imageUrl;

  @JsonKey(ignore: true)
  StorageFile? storageFile;
}

abstract class InterfaceToJson {
  Map<String, dynamic> toJson();
}

abstract class InterfaceDomainSearchable extends InterfaceToJson {
  List<String> searchFields();
}