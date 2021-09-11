import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:get/get.dart';

class WorkoutService extends AbstractFitnessStorageService<Workout> {
  WorkoutService();

  final TrainersService trainersService = Get.find();
  final String pathWorkoutMainImage = 'mainImage';

  @override
  Workout fromJson(Map<String, dynamic> map) {
    return Workout.fromJson(map);
  }

  @override
  Stream<List<Workout>> listenAll() {
    return trainersService.listenToWorkout();
  }

  @override
  String getStorageRef(User user, Workout workout) {
    return 'trainers/${user.uid}/workouts/${workout.uid}/$pathWorkoutMainImage';
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return trainersService.getWorkoutReference();
  }
}
