import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/domain/trainers.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:flutter/material.dart';

import 'firestore/abstract.absolute-firestore.service.dart';

class TrainersService extends AbstractAbsoluteFirestoreService<Trainers> {
  static TrainersService _instance;

  // Private constructor with the ._()
  TrainersService._()
      : super(
            collectionReference:
                FirebaseFirestore.instance.collection('trainers')) {
    _instance = this;
  }

  static TrainersService getInstance() {
    if (_instance == null) {
      _instance = TrainersService._();
    }
    return _instance;
  }

  DocumentReference getCurrentTrainerRef() {
    return this.collectionReference.doc(FirebaseAuth.instance.currentUser.uid);
  }

  CollectionReference getWorkoutReference() {
    return getCurrentTrainerRef().collection('workout');
  }

  Stream<List<Workout>> listenToWorkout() {
    return getWorkoutReference().snapshots().map((QuerySnapshot event) =>
        event.docs.map((doc) => Workout.fromJson(doc.id, doc.data())).toList());
  }

  @override
  Trainers mapSnapshotToModel(DocumentSnapshot snapshot) {
    return Trainers.fromJson(snapshot.id, snapshot.data());
  }
}
