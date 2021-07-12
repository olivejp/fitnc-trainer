import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/trainers.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:flutter/material.dart';

import 'firestore/abstract.absolute-firestore.service.dart';

class TrainersService extends AbstractAbsoluteFirestoreService<Trainers> {
  static TrainersService? _instance;

  // Private constructor with the ._()
  TrainersService._() : super(collectionReference: FirebaseFirestore.instance.collection('trainers')) {
    _instance = this;
  }

  static TrainersService getInstance() {
    if (_instance == null) {
      _instance = TrainersService._();
    }
    return _instance!;
  }

  DocumentReference getCurrentTrainerRef() {
    return this.collectionReference.doc(FirebaseAuth.instance.currentUser?.uid);
  }

  CollectionReference getWorkoutReference() {
    return getCurrentTrainerRef().collection('workout');
  }

  CollectionReference getAbonneReference() {
    return getCurrentTrainerRef().collection('abonne');
  }

  CollectionReference getExerciceReference() {
    return getCurrentTrainerRef().collection('exercice');
  }

  CollectionReference getWorkoutSetsReference(Workout workout) {
    return getWorkoutReference().doc(workout.uid).collection('sets');
  }

  Stream<List<WorkoutSet?>> listenToWorkoutStep(Workout workout) {
    return getWorkoutSetsReference(workout)
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((doc) => WorkoutSet.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Workout?>> listenToWorkout() {
    return getWorkoutReference()
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((doc) => Workout.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Abonne?>> listenToAbonne() {
    return getAbonneReference()
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((doc) => Abonne.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Exercice?>> listenToExercice() {
    return getExerciceReference()
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((doc) => Exercice.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<DropdownMenuItem<Exercice>>> getExerciceStreamDropdownMenuItem() {
    return getExerciceReference()
        .orderBy('name')
        .snapshots()
        .map((QuerySnapshot querysnapshot) => querysnapshot.docs.map((QueryDocumentSnapshot queryDocSnapshot) {
              Exercice exercice = Exercice.fromJson(queryDocSnapshot.data() as Map<String, dynamic>);
              ImageProvider? provider = exercice.imageUrl != null ? NetworkImage(exercice.imageUrl!) : null;
              return DropdownMenuItem(
                child: Row(children: [
                  CircleAvatar(
                    foregroundImage: provider,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(exercice.name),
                  ),
                ]),
                value: exercice,
              );
            }).toList());
  }

  @override
  Trainers mapSnapshotToModel(DocumentSnapshot snapshot) {
    return Trainers.fromJson(snapshot.data() as Map<String, dynamic>);
  }
}
