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
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutSetService {
  final TrainersService trainersService = TrainersService.instance();

  // Private constructor with the ._()
  WorkoutSetService._() {
    _instance = this;
  }

  static WorkoutSetService? _instance;

  static WorkoutSetService getInstance() {
    _instance ??= WorkoutSetService._();
    return _instance!;
  }

  CollectionReference getWorkoutReference() {
    return trainersService.getCurrentTrainerRef().collection('workout');
  }

  CollectionReference getWorkoutSetsReference(Workout workout) {
    return getWorkoutReference().doc(workout.uid).collection('sets');
  }

  Stream<List<WorkoutSet?>> listenToWorkoutStep(Workout workout) {
    return getWorkoutSetsReference(workout)
        .orderBy('order')
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((doc) => WorkoutSet.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<WorkoutSetDto?>> listenToWorkoutStepDto(Workout workout) {
    return getWorkoutSetsReference(workout)
        .orderBy('order')
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => WorkoutSet.fromJson(doc.data() as Map<String, dynamic>)).map((workoutSet) => mapToDto(workoutSet)).toList())
        .asyncMap((futures) => Future.wait(futures));
  }

  Future<WorkoutSetDto> mapToDto(WorkoutSet workoutSet) async {
    WorkoutSetDto dto = WorkoutSetDto.fromSet(workoutSet);

    // Recherche des infos de l'exercice
    if (workoutSet.uidExercice != null) {
      final DocumentSnapshot documentSnapshot = await trainersService.getExerciceReference().doc(workoutSet.uidExercice).get();
      final Exercice exercice = Exercice.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      dto.imageUrlExercice = exercice.imageUrl;
      dto.nameExercice = exercice.name;
      dto.typeExercice = exercice.typeExercice;
    }
    return dto;
  }
}
