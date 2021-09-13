import 'package:fitnc_trainer/service/workout.service.dart';
import 'package:fitness_domain/controller/abstract.controller.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/domain/workout_set.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutController extends SearchControllerMixin<Workout, WorkoutService> {
  final GlobalKey<FormFieldState> consigneKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> dropdownKey = GlobalKey<FormFieldState>();
  final WorkoutService workoutService = Get.find();

  final Rx<Workout> workout = Workout().obs;
  WorkoutSet set = WorkoutSet();
  Exercice? exerciceSelected;

  void init(Workout? workout) {
    if (workout != null) {
      this.workout.value = workout;
      this.workout.value.storageFile = StorageFile();
    } else {
      this.workout.value = Workout();
    }
  }

  void setStorageFile(StorageFile? file) {
    workout.update((Workout? workout) {
      if (workout != null) {
        workout.storageFile = file ?? StorageFile();
        workout.imageUrl = null;
      }
    });
  }

  Future<void> deleteWorkout(Workout workout) {
    return workoutService.delete(workout);
  }

  Future<void> saveWorkout() {
    return workoutService.save(workout.value);
  }

  set name(String value) {
    workout.value.name = value;
  }

  String get name => workout.value.name;

  set description(String? value) {
    workout.value.description = value;
  }

  String? get description => workout.value.description;

  set timerType(String? value) {
    workout.value.timerType = value;
  }

  String? get timerType => workout.value.timerType;

  void setExercice(Exercice? exerciceSelected) {
    this.exerciceSelected = exerciceSelected;
    set.uidExercice = this.exerciceSelected?.uid;
  }

  Future<StorageFile?> getStorageFile() {
    return workoutService.getFutureStorageFile(workout.value);
  }
}
