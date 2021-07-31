import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/service/abstract.absolute-firestore.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/domain/trainers.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TrainersService extends AbstractAbsoluteFirestoreService<Trainers> {
  static TrainersService? _instance;

  // Private constructor with the ._()
  TrainersService._() : super(collectionReference: FirebaseFirestore.instance.collection('trainers')) {
    _instance = this;
  }

  static TrainersService getInstance() {
    _instance ??= TrainersService._();
    return _instance!;
  }

  @override
  Trainers mapSnapshotToModel(DocumentSnapshot snapshot) {
    return Trainers.fromJson(snapshot.data() as Map<String, dynamic>);
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

  CollectionReference getProgrammeReference() {
    return getCurrentTrainerRef().collection('programme');
  }

  Stream<List<Workout?>> listenToWorkout() {
    return getWorkoutReference()
        .orderBy('createDate')
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((doc) => Workout.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<Workout?> listenToWorkouts() {
    return getWorkoutReference()
        .orderBy('createDate')
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((QueryDocumentSnapshot doc) => Workout.fromJson(doc.data() as Map<String, dynamic>)).toList())
        .asyncExpand((List<Workout> event) async* {
      for (final Workout workout in event) {
        yield workout;
      }
    });
  }

  Stream<List<Abonne?>> listenToAbonne() {
    return getAbonneReference()
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((doc) => Abonne.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Exercice?>> listenToExercice() {
    return getExerciceReference()
        .orderBy('createDate')
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((doc) => Exercice.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Programme?>> listenToProgramme() {
    return getProgrammeReference()
        .orderBy('createDate')
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((QueryDocumentSnapshot doc) => Programme.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<DropdownMenuItem<Exercice>>> getExerciceStreamDropdownMenuItem() {
    return getExerciceReference()
        .orderBy('name')
        .snapshots()
        .map((QuerySnapshot querysnapshot) => querysnapshot.docs.map((QueryDocumentSnapshot queryDocSnapshot) {
              final Exercice exercice = Exercice.fromJson(queryDocSnapshot.data() as Map<String, dynamic>);
              final ImageProvider? provider = exercice.imageUrl != null ? NetworkImage(exercice.imageUrl!) : null;
              return DropdownMenuItem<Exercice>(
                value: exercice,
                child: Row(children: [
                  CircleAvatar(
                    foregroundImage: provider,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(exercice.name),
                  ),
                ]),
              );
            }).toList());
  }
}
