import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirebaseFramework extends GetxService {
  List<Domain> listDomains = <Domain>[];
}

abstract class Domain {
  Domain(this.collectionName);

  final FirebaseFirestore instance = FirebaseFirestore.instance;
  final String collectionName;

  String? uid;
  String? parentUid;

  Map<String, List<Domain>>? hasMany;

  String getCollectionName() {
    return collectionName;
  }

  void add(Domain domain) {
    if (hasMany == null) hasMany = <String, List<Domain>>{};
    hasMany!.putIfAbsent(domain.collectionName, () => <Domain>[]);
  }

  void addSubdomain(Domain domain) {
    if (hasMany == null) hasMany = <String, List<Domain>>{};
    hasMany!.update(domain.collectionName, (List<Domain> list) {
      list.add(domain);
      return list;
    });
  }

  Future<void> save() async {
    if (uid == null) uid = instance.collection(collectionName).doc().id;

    instance.collection(collectionName).doc(uid).set(toJson());

    if (hasMany != null) {
      for (String key in hasMany!.keys) {
        List<Future<void>> listFuture = hasMany![key]!.map((Domain subdomain) => subdomain.save()).toList();
        Future.wait(listFuture);
      }
    }
  }

  Future<void> delete() {
    return instance.collection(collectionName).doc(uid).delete();
  }

  Map<String, dynamic> toJson();

  Domain fromJson(Map<String, dynamic> map);
}

class Personne extends Domain {
  Personne() : super('personne') {
    add(Animal());
  }

  String? lastname;
  String? firstname;

  @override
  Domain fromJson(Map<String, dynamic> map) {
    return Personne()
      ..uid = map['uid'] as String
      ..lastname = map['lastname'] as String
      ..firstname = map['firstname'] as String;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'uid': this.uid,
        'lastname': this.lastname,
        'firstname': this.firstname,
      };
}

class Animal extends Domain {
  Animal() : super('animal') {
    add(Collier());
  }

  String? name;

  Map<String, List<Domain>>? hasMany = {'collier': <Collier>[]};

  @override
  Domain fromJson(Map<String, dynamic> map) {
    return Animal()
      ..uid = map['uid'] as String
      ..name = map['name'] as String;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'uid': this.uid,
        'name': this.name,
      };
}

class Collier extends Domain {
  Collier() : super('collier');

  String? name;

  @override
  Domain fromJson(Map<String, dynamic> map) {
    return Collier()
      ..uid = map['uid'] as String
      ..name = map['name'] as String;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'uid': this.uid,
        'name': this.name,
      };
}
