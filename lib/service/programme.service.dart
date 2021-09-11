import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/domain/workout_schedule.domain.dart';
import 'package:fitness_domain/domain/workout_schedule.dto.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgrammeService extends AbstractFitnessStorageService<Programme> {
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  final TrainersService trainersService = Get.find();
  final String publishedProgrammeCollectionName = 'publishedProgrammes';

  @override
  Programme fromJson(Map<String, dynamic> map) {
    return Programme.fromJson(map);
  }

  @override
  Stream<List<Programme>> listenAll() {
    return trainersService.listenToProgramme();
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return trainersService.getProgrammeReference();
  }

  @override
  String getStorageRef(User user, Programme programme) {
    return 'trainers/${user.uid}/programmes/${programme.uid}';
  }

  ///
  /// Mapping d'un WorkoutSchedule en Future<WorkoutScheduleDto>
  ///
  Future<WorkoutScheduleDto> mapToFutureWorkoutScheduleDto(WorkoutSchedule e) {
    return trainersService
        .getWorkoutReference()
        .doc(e.uidWorkout)
        .get()
        .then((DocumentSnapshot<Object?> value) => Workout.fromJson(value.data()! as Map<String, dynamic>))
        .then((Workout value) {
      final WorkoutScheduleDto dto = WorkoutScheduleDto.fromSchedule(e);
      dto.nameWorkout = value.name;
      dto.imageUrlWorkout = value.imageUrl;
      return dto;
    });
  }

  ///
  ///Récupération de tous les Workouts sous forme d'une Liste de DropdownMenuItem
  ///
  Future<List<DropdownMenuItem<Workout>>> getWorkoutDropdownItems() async {
    final QuerySnapshot<Object?> query = await trainersService.getWorkoutReference().get();
    return query.docs
        .map((QueryDocumentSnapshot<Object?> e) => Workout.fromJson(e.data()! as Map<String, dynamic>))
        .map((Workout workout) => DropdownMenuItem<Workout>(value: workout, child: Text(workout.name)))
        .toList();
  }

  ///
  /// Publication du programme dans une collection où tous les utilisateurs pourront les trouver.
  ///
  Future<void> publishProgramme(Programme programme, {required bool sendStorage}) async {
    await save(programme);

    // Ouverture d'un batch.
    final WriteBatch batch = firestoreInstance.batch();

    final DocumentReference<Map<String, dynamic>> publishedProgrammeRef =
        firestoreInstance.collection(publishedProgrammeCollectionName).doc(programme.uid);

    batch.set(publishedProgrammeRef, programme.toJson());

    // Lecture de tous les workouts.
    final QuerySnapshot<Map<String, dynamic>> mapWorkouts =
        await trainersService.getProgrammeReference().doc(programme.uid).collection('workouts').get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> docs in mapWorkouts.docs) {
      final DocumentReference<Map<String, dynamic>> docRef = publishedProgrammeRef.collection('workouts').doc(docs.id);
      batch.set(docRef, docs.data());
    }

    batch.commit().then((_) {
      programme.available = true;
      programme.publishDate = FieldValue.serverTimestamp();
      return save(programme);
    });
  }

  ///
  /// Dépublication du programme dans une collection.
  ///
  Future<void> unpublishProgramme(Programme programme, {required bool sendStorage}) async {
    programme.available = false;
    await save(programme);

    final DocumentReference<Map<String, dynamic>> programmeRef =
        firestoreInstance.collection(publishedProgrammeCollectionName).doc(programme.uid);

    // Ouverture d'un batch.
    final WriteBatch batch = firestoreInstance.batch();

    // Suppression du programme publié.
    batch.delete(programmeRef);

    // Suppression de tous les Workouts.
    final QuerySnapshot<Map<String, dynamic>> values = await programmeRef.collection('workouts').get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> element in values.docs) {
      batch.delete(element.reference);
    }

    batch.commit();
  }
}
