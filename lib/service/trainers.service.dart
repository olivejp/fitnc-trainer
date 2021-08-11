import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/service/abstract.absolute-firestore.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/domain/trainers.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TrainersService extends AbstractAbsoluteFirestoreService<Trainers> {
  // Private constructor with the ._()
  TrainersService._() : super(collectionReference: FirebaseFirestore.instance.collection('trainers')) {
    _instance = this;
  }

  factory TrainersService.instance() {
    _instance ??= TrainersService._();
    return _instance!;
  }

  static TrainersService? _instance;

  @override
  Trainers mapSnapshotToModel(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Trainers.fromJson(snapshot.data()!);
  }

  DocumentReference getCurrentTrainerRef() {
    return collectionReference.doc(FirebaseAuth.instance.currentUser?.uid);
  }

  CollectionReference<Map<String, dynamic>> getWorkoutReference() {
    return getCurrentTrainerRef().collection('workout');
  }

  CollectionReference<Map<String, dynamic>> getAbonneReference() {
    return getCurrentTrainerRef().collection('abonne');
  }

  CollectionReference<Map<String, dynamic>> getExerciceReference() {
    return getCurrentTrainerRef().collection('exercice');
  }

  CollectionReference<Map<String, dynamic>> getProgrammeReference() {
    return getCurrentTrainerRef().collection('programme');
  }

  Stream<List<Workout>> listenToWorkout() {
    return getWorkoutReference().orderBy('createDate').snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Workout.fromJson(doc.data())).toList());
  }

  Stream<List<Abonne>> listenToAbonne() {
    return getAbonneReference().snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Abonne.fromJson(doc.data())).toList());
  }

  Stream<List<Exercice>> listenToExercice() {
    return getExerciceReference().orderBy('createDate').snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Exercice.fromJson(doc.data())).toList());
  }

  Stream<List<Programme>> listenToProgramme() {
    return getProgrammeReference().orderBy('createDate').snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Programme.fromJson(doc.data())).toList());
  }

  Stream<List<DropdownMenuItem<Exercice>>> getExerciceStreamDropdownMenuItem() {
    return getExerciceReference().orderBy('name').snapshots().map(
        (QuerySnapshot<Map<String, dynamic>> querysnapshot) => querysnapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> queryDocSnapshot) {
              final Exercice exercice = Exercice.fromJson(queryDocSnapshot.data());
              final ImageProvider? provider = exercice.imageUrl != null ? NetworkImage(exercice.imageUrl!) : null;
              return DropdownMenuItem<Exercice>(
                value: exercice,
                child: Row(children: <Widget>[
                  CircleAvatar(
                    foregroundImage: provider,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(exercice.name!),
                  ),
                ]),
              );
            }).toList());
  }
}
