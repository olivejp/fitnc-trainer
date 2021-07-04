import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';

import 'firestore/abstract.absolute-firestore.service.dart';

class AbonneService extends AbstractAbsoluteFirestoreService<Abonne> {
  static AbonneService? _instance;

  // Private constructor with the ._()
  AbonneService._()
      : super(
            collectionReference:
                FirebaseFirestore.instance.collection('abonne')) {
    _instance = this;
  }

  static AbonneService getInstance() {
    if (_instance == null) {
      _instance = AbonneService._();
    }
    return _instance!;
  }

  DocumentReference getCurrentTrainerRef() {
    return this.collectionReference.doc(FirebaseAuth.instance.currentUser?.uid);
  }

  CollectionReference getWorkoutReference() {
    return getCurrentTrainerRef().collection('workout');
  }

  Stream<List<Workout?>> listenToWorkout() {
    return getWorkoutReference().snapshots().map((QuerySnapshot event) => event
        .docs
        .map((doc) => Workout.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  @override
  Abonne mapSnapshotToModel(DocumentSnapshot snapshot) {
    return Abonne.fromJson(snapshot.data() as Map<String, dynamic>);
  }
}
