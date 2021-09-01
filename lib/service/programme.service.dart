import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.dto.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgrammeService extends AbstractFitnessCrudService<Programme> with MixinFitnessStorageService<Programme> {
  final TrainersService trainersService = Get.find();

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
  ///Sauvegarde un programme dans Firebase
  ///
  Future<void> saveProgramme(Programme programme, {required bool sendStorage}) {
    if (programme.uid != null) {
      if (sendStorage) {
        return eraseAndReplaceStorage(programme).then((_) => save(programme));
      } else {
        return save(programme);
      }
    } else {
      programme.uid = getCollectionReference().doc().id;
      return createStorage(programme).then((_) => create(programme));
    }
  }

  ///
  /// Supprime un programme de Firebase et supprime tous les fichiers associés dans le Firestorage.
  ///
  Future<void> deleteProgramme(Programme programme) {
    return delete(programme).then((_) => deleteAllFiles(programme));
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
    programme.available = true;
    programme.publishDate = FieldValue.serverTimestamp();
    await saveProgramme(programme, sendStorage: sendStorage);

    // Ouverture d'un batch.
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    final DocumentReference<Map<String, dynamic>> programmeRef = FirebaseFirestore.instance.collection('publishedProgrammes').doc(programme.uid);

    batch.set(programmeRef, programme.toJson());

    // Lecture de tous les workouts.
    final QuerySnapshot<Map<String, dynamic>> mapWorkouts =
        await trainersService.getProgrammeReference().doc(programme.uid).collection('workouts').get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> docs in mapWorkouts.docs) {
      final DocumentReference<Map<String, dynamic>> docRef = programmeRef.collection('workouts').doc(docs.id);
      batch.set(docRef, docs.data());
    }

    batch.commit();
  }

  ///
  /// Dépublication du programme dans une collection.
  ///
  Future<void> unpublishProgramme(Programme programme, {required bool sendStorage}) async {
    programme.available = false;
    await saveProgramme(programme, sendStorage: sendStorage);

    final DocumentReference<Map<String, dynamic>> programmeRef = FirebaseFirestore.instance.collection('publishedProgrammes').doc(programme.uid);

    // Ouverture d'un batch.
    final WriteBatch batch = FirebaseFirestore.instance.batch();

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
