import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';

class FitnessUserService extends AbstractFitnessCrudService<FitnessUser> with MixinFitnessStorageService<FitnessUser> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final String collectionName = 'users';

  @override
  FitnessUser fromJson(Map<String, dynamic> map) {
    return FitnessUser.fromJson(map);
  }

  @override
  CollectionReference<Map<String, dynamic>> getCollectionReference() {
    return firebaseFirestore.collection(collectionName);
  }

  @override
  String getStorageRef(User user, FitnessUser domain) {
    return '$collectionName/${user.uid}';
  }

  @override
  Stream<List<FitnessUser>> listenAll() {
    return getCollectionReference().orderBy('createDate').snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => FitnessUser.fromJson(doc.data())).toList());
  }
}
