import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/published_programme.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/domain/workout_schedule.domain.dart';
import 'package:fitness_domain/domain/workout_schedule.dto.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgrammeService extends AbstractFitnessStorageService<Programme> {
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  final TrainersService trainersService = Get.find();
  final PublishedProgrammeService publishedProgrammeService = Get.find();

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

  @override
  Future<void> save(Programme programme) async {
    if (programme.available == true) {
      return super.save(programme).then((_) => refreshPublished(programme));
    } else {
      return super.save(programme);
    }
  }

  Future<void> refreshAllPublished() async {
    final List<Programme> listProgramme = (await getCollectionReference().where('available', isEqualTo: true).get())
        .docs
        .map((QueryDocumentSnapshot<Object?> e) => fromJson(e.data() as Map<String, dynamic>))
        .toList();

    for (final Programme programme in listProgramme) {
      await refreshPublished(programme);
    }
  }

  Future<void> refreshPublished(Programme programme) async {
    if (programme.available == true) {
      final Trainers? trainers = await trainersService.getCurrentTrainer();
      if (trainers == null) throw Exception('Aucun utilisateur connecté');
      return publishedProgrammeService.save(PublishedProgramme.fromProgramme(programme, trainers));
    }
  }

  @override
  Future<void> delete(Programme programme) {
    if (programme.available == true) {
      return unpublishProgramme(programme);
    } else {
      return super.delete(programme);
    }
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
  Future<void> publishProgramme(Programme programme) async {
    await save(programme);
    publishedProgrammeService.publish(programme).then((_) {
      programme.available = true;
      programme.publishDate = FieldValue.serverTimestamp();
      return save(programme);
    });
  }

  ///
  /// Dépublication du programme dans une collection.
  ///
  Future<void> unpublishProgramme(Programme programme) async {
    programme.available = false;
    await save(programme);
    publishedProgrammeService.unpublish(programme);
  }
}
