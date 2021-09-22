import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/programme.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

class WorkoutService extends AbstractFitnessStorageService<Workout> {
  WorkoutService();

  final TrainersService trainersService = Get.find();
  final ProgrammeService programmeService = Get.find();

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
    return 'trainers/${user.uid}/workouts/${workout.uid}';
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return trainersService.getWorkoutReference();
  }

  @override
  Future<void> delete(Workout domain) async {
    FirebaseFirestore.instance.collectionGroup(ProgrammeService.workoutScheduleCollectionName).get().then((_) => print('test')).catchError((error) => print(error.toString()));
    return super.delete(domain).catchError((Object? onError) => showToast('Impossible de supprimer le workout : ${onError.toString()}'));
  }
}
