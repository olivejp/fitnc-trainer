import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutSetService {
  WorkoutSetService(BuildContext context) {
    trainersService = Provider.of<TrainersService>(context, listen: false);
  }

  late TrainersService trainersService;

  CollectionReference getWorkoutReference() {
    return trainersService.getCurrentTrainerRef().collection('workout');
  }

  CollectionReference getWorkoutSetsReference(Workout workout) {
    return getWorkoutReference().doc(workout.uid).collection('sets');
  }

  Stream<List<WorkoutSet?>> listenToWorkoutStep(Workout workout) {
    return getWorkoutSetsReference(workout).orderBy('order').snapshots().map(
        (QuerySnapshot event) => event.docs
            .map((doc) =>
                WorkoutSet.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<WorkoutSetDto?>> listenToWorkoutStepDto(Workout workout) {
    return getWorkoutSetsReference(workout)
        .orderBy('order')
        .snapshots()
        .map((event) => event.docs
            .map((doc) =>
                WorkoutSet.fromJson(doc.data() as Map<String, dynamic>))
            .map((workoutSet) => mapToDto(workoutSet))
            .toList())
        .asyncMap((futures) => Future.wait(futures));
  }

  Future<WorkoutSetDto> mapToDto(WorkoutSet workoutSet) async {
    WorkoutSetDto dto = WorkoutSetDto.fromSet(workoutSet);

    // Recherche des infos de l'exercice
    if (workoutSet.uidExercice != null) {
      final DocumentSnapshot documentSnapshot = await trainersService
          .getExerciceReference()
          .doc(workoutSet.uidExercice)
          .get();
      final Exercice exercice =
          Exercice.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      dto.imageUrlExercice = exercice.imageUrl;
      dto.nameExercice = exercice.name;
      dto.typeExercice = exercice.typeExercice;
    }
    return dto;
  }
}
