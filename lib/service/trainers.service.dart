import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_domain/domain/abonne.domain.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class TrainersService extends AbstractFitnessStorageService<Trainers> {
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  @override
  Trainers fromJson(Map<String, dynamic> map) {
    return Trainers.fromJson(map);
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return firestoreInstance.collection('trainers');
  }

  @override
  String getStorageRef(User user, Trainers domain) {
    return "trainers/${user.uid}/mainImage";
  }

  @override
  Stream<List<Trainers>> listenAll() {
    return getCollectionReference().snapshots().map((QuerySnapshot querySnapshot) =>
        querySnapshot.docs.map((QueryDocumentSnapshot docSnapshot) => Trainers.fromJson(docSnapshot.data() as Map<String, dynamic>)).toList());
  }

  @override
  Trainers mapSnapshotToModel(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Trainers.fromJson(snapshot.data()!);
  }

  Future<Trainers?> getCurrentTrainer() {
    final User? user = authInstance.currentUser;
    if (user == null) throw Exception('noUserConnected'.tr);
    return read(user.uid);
  }

  DocumentReference<Object?> getCurrentTrainerRef() {
    return getCollectionReference().doc(authInstance.currentUser?.uid);
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

  Stream<List<Exercice>> listenToExercise() {
    return getExerciceReference().orderBy('createDate').snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Exercice.fromJson(doc.data())).toList());
  }

  Stream<List<Programme>> listenToProgram() {
    return getProgrammeReference().orderBy('createDate').snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Programme.fromJson(doc.data())).toList());
  }

  Stream<List<DropdownMenuItem<Exercice>>> getExerciseStreamDropdownMenuItem() {
    return getExerciceReference().orderBy('name').snapshots().map(
        (QuerySnapshot<Map<String, dynamic>> querySnapshot) => querySnapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> queryDocSnapshot) {
              final Exercice exercise = Exercice.fromJson(queryDocSnapshot.data());
              final ImageProvider? provider = exercise.imageUrl != null ? NetworkImage(exercise.imageUrl!) : null;
              return DropdownMenuItem<Exercice>(
                value: exercise,
                child: Row(children: <Widget>[
                  CircleAvatar(
                    foregroundImage: provider,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(exercise.name),
                  ),
                ]),
              );
            }).toList());
  }
}
